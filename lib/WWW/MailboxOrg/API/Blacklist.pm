package WWW::MailboxOrg::API::Blacklist;

# ABSTRACT: Blacklist API

use Moo;
use MooX::Singleton;
use Carp qw(croak);
use Params::ValidationCompiler qw(validation_for);
use Types::Standard qw(Str);

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

my %validators = (
    add => validation_for(
        params => {
            account => { type => Str, optional => 0 },
            email   => { type => Str, optional => 0 },
        },
    ),
    del => validation_for(
        params => {
            account => { type => Str, optional => 0 },
            email   => { type => Str, optional => 0 },
        },
    ),
    list => validation_for(
        params => {
            account => { type => Str, optional => 0 },
        },
    ),
);

sub add {
    my ($self, %params) = @_;
    my $v = $validators{'add'};
    %params = $v->(%params) if $v;
    return $self->_rpc('blacklist.add', \%params);
}

sub del {
    my ($self, %params) = @_;
    my $v = $validators{'del'};
    %params = $v->(%params) if $v;
    return $self->_rpc('blacklist.del', \%params);
}

sub list {
    my ($self, %params) = @_;
    my $v = $validators{'list'};
    %params = $v->(%params) if $v;
    return $self->_rpc('blacklist.list', \%params);
}

1;

__END__

=head1 NAME

WWW::MailboxOrg::API::Blacklist - Blacklist API


=method add

    $api->blacklist->add(
        account => 'admin@example.com',
        email   => 'spam@example.com',
    );

Add an email to blacklist. Required: C<account>, C<email>.

=method del

    $api->blacklist->del(
        account => 'admin@example.com',
        email   => 'spam@example.com',
    );

Remove an email from blacklist.

=method list

    $api->blacklist->list(account => 'admin@example.com');

List blacklist entries. Required: C<account>.

=cut