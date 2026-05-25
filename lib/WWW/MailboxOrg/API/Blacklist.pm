package WWW::MailboxOrg::API::Blacklist;

# ABSTRACT: Blacklist API

use Moo;
with 'WWW::MailboxOrg::Role::API';
use Params::ValidationCompiler qw( validation_for );
use Types::Standard qw( Str );

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

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

=method add

    $api->blacklist->add(
        account => 'admin@example.com',
        email   => 'spam@example.com',
    );

Add an email to blacklist. Required: C<account>, C<email>.

=cut

sub add {
    my ( $self, %params ) = @_;
    my $v = $validators{'add'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'blacklist.add', \%params );
}

=method del

    $api->blacklist->del(
        account => 'admin@example.com',
        email   => 'spam@example.com',
    );

Remove an email from blacklist.

=cut

sub del {
    my ( $self, %params ) = @_;
    my $v = $validators{'del'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'blacklist.del', \%params );
}

=method list

    $api->blacklist->list(account => 'admin@example.com');

List blacklist entries. Required: C<account>.

=cut

sub list {
    my ( $self, %params ) = @_;
    my $v = $validators{'list'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'blacklist.list', \%params );
}

1;
