package WWW::MailboxOrg::Role::API;

# ABSTRACT: Shared API controller behavior (client, _rpc)

use Moo::Role;
use Carp qw(croak);

sub _rpc {
    my ( $self, $method, @params ) = @_;
    my $client = $self->client or croak "No client set";
    return $client->call( $method, @params );
}

1;

__END__

=head1 NAME

WWW::MailboxOrg::Role::API - Shared API controller behavior

=cut