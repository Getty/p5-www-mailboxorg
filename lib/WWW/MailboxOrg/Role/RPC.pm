package WWW::MailboxOrg::Role::RPC;

# ABSTRACT: Role for RPC API controllers

use Moo::Role;

requires 'client';

sub _rpc {
    my ($self, $method, @params) = @_;
    my $client = $self->client or croak "No client set";
    return $client->call($method, @params);
}

1;
