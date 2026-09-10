use strict;
use warnings;

use Test::More;
use Test::Exception;

use HTTP::Response;
use WWW::MailboxOrg::LWPIO;
use WWW::MailboxOrg::JSONRPCRequest;

# Produktiv-ENV abklemmen, damit die Tests deterministisch bleiben
delete @ENV{ grep { /^WWW_MAILBOXORG_/ } keys %ENV };

# Regressionsschutz für GitHub-Issue #1 / karr #4:
# LWPIO muss den deklarierten HTTP-Client (LWP::UserAgent) benutzen, nicht
# Mojo::UserAgent. Der Test läuft komplett offline über eine Fake-UA, die
# HTTP::Response-Objekte zurückgibt und den abgeschickten Request aufzeichnet.

# Minimales Fake-UserAgent-Backend: ->request($http_req) liefert eine
# vorbereitete HTTP::Response und merkt sich den letzten Request.
{
  package FakeUA;
  sub new       { bless { response => $_[1] }, $_[0] }
  sub request   { my ( $self, $req ) = @_; $self->{last} = $req; $self->{response} }
  sub last_req  { $_[0]->{last} }
}

sub _req {
  WWW::MailboxOrg::JSONRPCRequest->new(
    method  => 'account.get',
    params  => { account => 'user@example.com' },
    id      => 1,
    url     => 'https://api.mailbox.org/v1',
    headers => { 'HPLS-AUTH' => 'session-abc' },
  );
}

sub _response {
  my ( $code, $msg, $body ) = @_;
  HTTP::Response->new( $code, $msg, [ 'Content-Type' => 'application/json' ], $body );
}

subtest 'Default-UA ist LWP::UserAgent (nicht Mojo)' => sub {
  my $io = WWW::MailboxOrg::LWPIO->new;
  isa_ok( $io->ua, 'LWP::UserAgent', 'ua-Attribut' );
  is( $io->timeout, 30, 'Default-Timeout 30s' );
};

subtest 'Erfolgreiche Antwort wird geparst' => sub {
  my $fake = FakeUA->new(
    _response( 200, 'OK', '{"jsonrpc":"2.0","id":1,"result":{"account":"user@example.com"}}' )
  );
  my $io  = WWW::MailboxOrg::LWPIO->new( ua => $fake );
  my $res = $io->call( _req() );

  ok( $res->is_success,                         'Antwort erfolgreich' );
  is( $res->result->{account}, 'user@example.com', 'result korrekt geparst' );
  is( $res->id, 1,                              'id korrekt' );
};

subtest 'Request wird korrekt aufgebaut' => sub {
  my $fake = FakeUA->new( _response( 200, 'OK', '{"result":{}}' ) );
  my $io   = WWW::MailboxOrg::LWPIO->new( ua => $fake );
  $io->call( _req() );

  my $sent = $fake->last_req;
  isa_ok( $sent, 'HTTP::Request',                  'abgeschickter Request' );
  is( $sent->method, 'POST',                       'POST-Methode' );
  is( $sent->uri, 'https://api.mailbox.org/v1',    'URL korrekt' );
  is( $sent->header('Content-Type'), 'application/json', 'Content-Type application/json' );
  is( $sent->header('HPLS-AUTH'), 'session-abc',   'HPLS-AUTH-Header gesetzt' );
  like( $sent->content, qr/"method"\s*:\s*"account\.get"/, 'JSON-Body enthält method' );
};

subtest 'Kein HPLS-AUTH ohne Token' => sub {
  my $fake = FakeUA->new( _response( 200, 'OK', '{"result":{}}' ) );
  my $io   = WWW::MailboxOrg::LWPIO->new( ua => $fake );
  my $req  = WWW::MailboxOrg::JSONRPCRequest->new(
    method => 'test', id => 1, url => 'https://api.mailbox.org/v1',
  );
  $io->call( $req );
  ok( !$fake->last_req->header('HPLS-AUTH'), 'kein HPLS-AUTH-Header ohne Token' );
};

subtest 'HTTP-Transportfehler liefert JSON-RPC-Fehler' => sub {
  my $fake = FakeUA->new( _response( 500, 'Internal Server Error', 'boom' ) );
  my $io   = WWW::MailboxOrg::LWPIO->new( ua => $fake );
  my $res  = $io->call( _req() );

  ok( $res->has_error,                     'Fehler-Response' );
  is( $res->error->{code}, -32300,         'Transport-Fehlercode -32300' );
  like( $res->error->{message}, qr/500/,   'Statuszeile in Nachricht' );
  is( $res->id, 1,                         'id bleibt erhalten' );
};

subtest 'JSON-RPC-Fehler im Body (HTTP 200) wird durchgereicht' => sub {
  my $fake = FakeUA->new(
    _response( 200, 'OK', '{"jsonrpc":"2.0","id":1,"error":{"code":-32601,"message":"Method not found"}}' )
  );
  my $io  = WWW::MailboxOrg::LWPIO->new( ua => $fake );
  my $res = $io->call( _req() );

  ok( $res->has_error,                          'Fehler aus Body' );
  is( $res->error->{code}, -32601,              'Fehlercode aus Body' );
  is( $res->error->{message}, 'Method not found', 'Fehlermeldung aus Body' );
};

subtest 'Leere/ungültige Antwort liefert -32603' => sub {
  my $fake = FakeUA->new( _response( 200, 'OK', 'not json' ) );
  my $io   = WWW::MailboxOrg::LWPIO->new( ua => $fake );
  my $res  = $io->call( _req() );

  ok( $res->has_error,             'Fehler bei ungültigem JSON' );
  is( $res->error->{code}, -32603, 'Fehlercode -32603' );
};

done_testing;
