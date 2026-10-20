use strict;
use warnings;

use Test::More;

use WWW::MailboxOrg::JSONRPCRequest;
use WWW::MailboxOrg::JSONRPCResponse;

# "hat eine id" muss heissen: die id hat einen Wert. Eine Notification traegt
# keine id, eine Fehlerantwort kann eine null-id tragen - beides ist keine id.

subtest 'Request mit id meldet has_id' => sub {
  my $req = WWW::MailboxOrg::JSONRPCRequest->new(
    method => 'account.get',
    id     => 1,
    url    => 'https://api.mailbox.org/v1',
  );

  ok( $req->has_id, 'Request mit id meldet has_id' );
  is( $req->id, 1, 'id bleibt unveraendert' );
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
  is( $res->id, 1, 'id bleibt unveraendert' );
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

done_testing;
