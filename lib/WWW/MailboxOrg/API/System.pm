package WWW::MailboxOrg::API::System;

# ABSTRACT: System API (hello, test, capabilities)

use Moo;
use MooX::Singleton;
use Carp qw(croak);

our $VERSION = '0.002';

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _rpc {
    my ($self, $method, @params) = @_;
    my $client = $self->client or croak "No client set";
    return $client->call($method, @params);
}

sub hello {
    my ($self) = @_;
    return $self->_rpc('hello');
}

sub test {
    my ($self) = @_;
    return $self->_rpc('test');
}

sub capabilities {
    my ($self) = @_;
    return $self->_rpc('capabilities');
}

1;

__END__

=head1 NAME

WWW::MailboxOrg::API::System - System API (hello, test, capabilities)


=method hello

    my $result = $api->system->hello;

Get API hello response. No parameters required.

=method test

    my $result = $api->system->test;

Test API connection. Returns test result.

=method capabilities

    my $caps = $api->system->capabilities;

Get API capabilities. Returns capability list.

=cut