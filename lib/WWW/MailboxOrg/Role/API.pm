package WWW::MailboxOrg::Role::API;

# ABSTRACT: Shared API controller behavior (client, _rpc)

use Moo::Role;
use Carp qw(croak);

=head1 DESCRIPTION

This role provides the C<_rpc> method used by all API controllers
to make JSON-RPC calls via the client.

=cut

sub _rpc {
    my ( $self, $method, @params ) = @_;
    my $client = $self->client or croak "No client set";
    return $client->call( $method, @params );
}

1;

__END__

=head1 METHODS

=method _rpc

    $self->_rpc('method.name', \%params);

Make a JSON-RPC call via the client. The C<client> attribute must
be set. Returns the result from the RPC call.

=cut