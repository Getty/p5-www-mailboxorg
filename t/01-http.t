use strict;
use warnings;

use Test::More;
use Test::Exception;
use lib 't/lib';

use WWW::MailboxOrg;
use WWW::MailboxOrg::MockIO;

# Produktiv-ENV abklemmen, damit die Tests deterministisch bleiben
delete @ENV{ grep { /^WWW_MAILBOXORG_/ } keys %ENV };

subtest 'RPC-Request wird korrekt gebaut' => sub {
  my $mock = WWW::MailboxOrg::MockIO->new;
  my $client = WWW::MailboxOrg->new(
    user     => 'test@example.com',
    password => 'secret',
    io       => $mock,
  );

  $client->call( 'account.get', { account => 'user@example.com' } );

  my $req = $mock->last_call;
  is( $req->method,              'account.get',             'method korrekt' );
  is( $req->params->{account},   'user@example.com',        'params korrekt' );
  ok( $req->has_id,                                          'id vorhanden' );
  is( $req->jsonrpc,             '2.0',                     'JSON-RPC Version 2.0' );
  is( $req->url,                 'https://api.mailbox.org/v1', 'URL korrekt' );
};

subtest 'Flache Argumentliste wird als benannter Parameter gesendet' => sub {
  my $mock = WWW::MailboxOrg::MockIO->new;
  my $client = WWW::MailboxOrg->new(
    user     => 'test@example.com',
    password => 'secret',
    io       => $mock,
  );

  $client->call( 'account.set', account => 'user@example.com', active => 1 );

  my $req = $mock->last_call;
  is_deeply(
    $req->params,
    { account => 'user@example.com', active => 1 },
    'Parameter kommen als benanntes Objekt an',
  );
  ok( defined $req->id, 'id vorhanden' );
};

subtest 'Notification reist ohne id und ohne Parameterverlust' => sub {
  my $mock = WWW::MailboxOrg::MockIO->new;
  my $client = WWW::MailboxOrg->new(
    user     => 'test@example.com',
    password => 'secret',
    io       => $mock,
  );

  $client->notification( 'account.set', account => 'user@example.com', active => 1 );

  my $req = $mock->last_call;
  ok( !defined $req->id, 'keine id bei einer Notification' );
  is_deeply(
    $req->params,
    { account => 'user@example.com', active => 1 },
    'Parameter kommen als benanntes Objekt an',
  );
};

subtest 'Ungerade Parameterliste croakt' => sub {
  my $mock = WWW::MailboxOrg::MockIO->new;
  my $client = WWW::MailboxOrg->new(
    user     => 'test@example.com',
    password => 'secret',
    io       => $mock,
  );

  dies_ok { $client->call( 'account.set', 'user@example.com' ) }
    'Exception bei ungerader Parameterliste';
  like( $@, qr/Odd number of named parameters/, 'Exception nennt den Fehlergrund' );
};

subtest 'HPLS-AUTH Header' => sub {
  my $mock = WWW::MailboxOrg::MockIO->new;
  my $client = WWW::MailboxOrg->new(
    user     => 'test@example.com',
    password => 'secret',
    io       => $mock,
  );

  $client->call('test');
  ok( !$mock->last_call->headers->{'HPLS-AUTH'}, 'kein HPLS-AUTH ohne token' );

  $client->_set_token('session-abc');
  $client->call('test');
  is( $mock->last_call->headers->{'HPLS-AUTH'}, 'session-abc', 'HPLS-AUTH gesetzt wenn token vorhanden' );

  $client->clear_token;
};

subtest 'IDs werden hochgezählt' => sub {
  my $mock = WWW::MailboxOrg::MockIO->new;
  my $client = WWW::MailboxOrg->new(
    user     => 'test@example.com',
    password => 'secret',
    io       => $mock,
  );

  $client->call('test');
  my $id1 = $mock->last_call->id;
  $client->call('test');
  my $id2 = $mock->last_call->id;

  ok( defined $id1,       'id1 definiert' );
  ok( defined $id2,       'id2 definiert' );
  ok( $id2 > $id1,        'id wird hochgezählt' );
};

subtest 'Error-Response wirft Exception' => sub {
  my $mock = WWW::MailboxOrg::MockIO->new;
  $mock->add_response( 'failing.method', {
    _error => { code => -32600, message => 'Invalid request' },
  });

  my $client = WWW::MailboxOrg->new(
    user     => 'test@example.com',
    password => 'secret',
    io       => $mock,
  );

  dies_ok { $client->call('failing.method') } 'Exception bei Fehler-Response';
  like( $@, qr/Invalid request/, 'Exception enthält Fehlermeldung' );
};

subtest 'Login extrahiert Session-Token' => sub {
  my $mock = WWW::MailboxOrg::MockIO->new;
  $mock->add_response( 'auth',   { session => 'session-xyz-123' } );
  $mock->add_response( 'deauth', {} );

  my $client = WWW::MailboxOrg->new(
    user     => 'test@example.com',
    password => 'secret',
    io       => $mock,
  );

  $client->login;
  is( $client->token, 'session-xyz-123', 'token nach login gesetzt' );
};

subtest 'Logout löscht Session-Token' => sub {
  my $mock = WWW::MailboxOrg::MockIO->new;
  $mock->add_response( 'auth',   { session => 'session-xyz' } );
  $mock->add_response( 'deauth', {} );

  my $client = WWW::MailboxOrg->new(
    user     => 'test@example.com',
    password => 'secret',
    io       => $mock,
  );

  $client->login;
  $client->logout;

  ok( !$client->token, 'token nach logout gelöscht' );
};

done_testing;
