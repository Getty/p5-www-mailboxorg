use strict;
use warnings;

use Test::More;
use lib 't/lib';

use JSON::MaybeXS qw(decode_json encode_json);
use HTTP::Response;

use WWW::MailboxOrg;
use WWW::MailboxOrg::JSONRPCRequest;
use WWW::MailboxOrg::JSONRPCResponse;
use WWW::MailboxOrg::LWPIO;
use WWW::MailboxOrg::MockIO;

# Minimales Fake-UserAgent-Backend: ->request($http_req) liefert eine
# vorbereitete HTTP::Response und merkt sich den letzten Request.
{
  package FakeUA;
  sub new      { bless { response => $_[1] }, $_[0] }
  sub request  { my ( $self, $req ) = @_; $self->{last} = $req; $self->{response} }
  sub last_req { $_[0]->{last} }
}

# "hat eine id" muss heißen: die id hat einen Wert. Eine Notification trägt
# keine id, eine Fehlerantwort kann eine null-id tragen - beides ist keine id.

subtest 'Request mit id meldet has_id' => sub {
  my $req = WWW::MailboxOrg::JSONRPCRequest->new(
    method => 'account.get',
    id     => 1,
    url    => 'https://api.mailbox.org/v1',
  );

  ok( $req->has_id, 'Request mit id meldet has_id' );
  is( $req->id, 1, 'id bleibt unverändert' );
};

subtest 'Request ohne id meldet kein has_id' => sub {
  my $req = WWW::MailboxOrg::JSONRPCRequest->new(
    method => 'account.get',
    id     => undef,
    url    => 'https://api.mailbox.org/v1',
  );

  ok( !$req->has_id, 'Request ohne id meldet kein has_id' );
  is( $req->id, undef, 'id bleibt undef' );
};

subtest 'Response mit id meldet has_id' => sub {
  my $res = WWW::MailboxOrg::JSONRPCResponse->new(
    result => { account => 'user@example.com' },
    id     => 1,
  );

  ok( $res->has_id, 'Response mit id meldet has_id' );
  is( $res->id, 1, 'id bleibt unverändert' );
};

subtest 'Response ohne id meldet kein has_id' => sub {
  my $res = WWW::MailboxOrg::JSONRPCResponse->new(
    error => { code => -32600, message => 'Invalid request' },
    id    => undef,
  );

  ok( !$res->has_id, 'Response mit null-id meldet kein has_id' );

  my $without_member = WWW::MailboxOrg::JSONRPCResponse->new(
    error => { code => -32700, message => 'Parse error' },
  );

  ok( !$without_member->has_id, 'Response ohne id-Mitglied meldet kein has_id' );
};

subtest 'Notification wird ohne id-Mitglied gebaut' => sub {
  my $mock = WWW::MailboxOrg::MockIO->new;
  my $client = WWW::MailboxOrg->new(
    user     => 'test@example.com',
    password => 'secret',
    io       => $mock,
  );

  $client->notification( 'mail.send', to => 'user@example.com' );

  my $req = $mock->last_call;
  ok( !$req->has_id, 'die Notification trägt keine id' );

  my $hash = $req->to_hash;
  ok( !exists $hash->{id}, 'to_hash enthält kein id-Mitglied' );

  my $body = decode_json( encode_json($hash) );
  ok( !exists $body->{id}, 'der kodierte Body enthält kein id-Mitglied' );
  is( $body->{method}, 'mail.send', 'die Methode steht im Body' );
};

subtest 'Der Transport schickt eine Notification ohne id' => sub {
  my $fake = FakeUA->new(
    HTTP::Response->new( 200, 'OK', [ 'Content-Type' => 'application/json' ], '{"result":{}}' )
  );
  my $io = WWW::MailboxOrg::LWPIO->new( ua => $fake );

  $io->call(
    WWW::MailboxOrg::JSONRPCRequest->new(
      method => 'mail.send',
      params => { to => 'user@example.com' },
      id     => undef,
      url    => 'https://api.mailbox.org/v1',
    )
  );

  my $content = $fake->last_req->content;
  ok( !exists decode_json($content)->{id}, 'der abgeschickte Body enthält kein id-Mitglied' );
  unlike( $content, qr/"id"/, 'der abgeschickte Body nennt kein id' );
};

subtest 'Ein Call behält sein id-Mitglied' => sub {
  my $mock = WWW::MailboxOrg::MockIO->new;
  my $client = WWW::MailboxOrg->new(
    user     => 'test@example.com',
    password => 'secret',
    io       => $mock,
  );

  $client->call( 'account.get', account => 'user@example.com' );

  my $body = decode_json( encode_json( $mock->last_call->to_hash ) );
  ok( exists $body->{id}, 'der kodierte Body eines Aufrufs enthält ein id-Mitglied' );
  ok( defined $body->{id}, 'das id hat einen Wert' );
};

done_testing;
