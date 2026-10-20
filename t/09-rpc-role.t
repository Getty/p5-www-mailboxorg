use strict;
use warnings;

use Test::More;
use Test::Exception;

use WWW::MailboxOrg::Role::RPC;

# Ein Objekt ohne gesetzten Client muss mit "No client set" sterben. Ohne das
# geladene Carp ist die Rolle gar nicht übersetzbar: croak "No client set" ist
# unter strict subs ein Syntaxfehler, die Rolle wird nie geladen.

{
  package NoClient;

  use Moo;

  has client => ( is => 'ro' );

  with 'WWW::MailboxOrg::Role::RPC';

  sub do_rpc { $_[0]->_rpc('account.get') }
}

subtest 'Ein Aufruf ohne Client croakt mit No client set' => sub {
  my $obj = NoClient->new;

  dies_ok { $obj->do_rpc } 'der Aufruf ohne Client stirbt';
  like( $@, qr/No client set/, 'die Meldung nennt den Grund' );
  unlike( $@, qr/Undefined subroutine/, 'die Meldung ist keine fehlende Routine' );
};

subtest 'Die Rolle komponiert croak nicht in ihre Verbraucher' => sub {
  ok( !NoClient->can('croak'), 'der Verbraucher hat kein croak' );
};

done_testing;
