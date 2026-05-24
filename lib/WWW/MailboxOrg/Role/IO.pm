package WWW::MailboxOrg::Role::IO;

# ABSTRACT: Interface role for pluggable JSON-RPC backends

use Moo::Role;

requires 'call';

1;

__END__

=head1 SYNOPSIS

    package My::AsyncIO;
    use Moo;
    with 'WWW::MailboxOrg::Role::IO';

    sub call {
        my ($self, $req) = @_;
        my $result = $self->_do_rpc($req);
        return WWW::MailboxOrg::JSONRPCResponse->new(%$result);
    }

=head1 DESCRIPTION

This role defines the interface that JSON-RPC backends must implement.
L<WWW::MailboxOrg::Role::HTTP> delegates all RPC communication through this
interface, making it possible to swap out the transport layer.

The default backend is L<WWW::MailboxOrg::LWPIO> (synchronous, using
L<Mojo::UserAgent>). To use an async event loop, implement this role.

=head1 REQUIRED METHODS

=head2 call($req)

Execute a L<WWW::MailboxOrg::JSONRPCRequest>. Receives the request object
with C<method>, C<params>, and C<id> already set.

Must return a L<WWW::MailboxOrg::JSONRPCResponse>.

=cut