package WWW::MailboxOrg::Role::RPC;

# ABSTRACT: Role for RPC API controllers

use Moo::Role;

our $VERSION = '0.002';

requires 'client';

sub _rpc {
    my ($self, $method, @params) = @_;
    my $client = $self->client or croak "No client set";
    return $client->call($method, @params);
}

1;

__END__

=head1 NAME

WWW::MailboxOrg::Role::RPC - Role for RPC API controllers

=cut