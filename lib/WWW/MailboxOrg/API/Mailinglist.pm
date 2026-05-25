package WWW::MailboxOrg::API::Mailinglist;

# ABSTRACT: Mailing list API

use Moo;
with 'WWW::MailboxOrg::Role::API';
use Params::ValidationCompiler qw( validation_for );
use Types::Standard qw( Str ArrayRef HashRef Bool );

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

my %validators = (
    add => validation_for(
        params => {
            account  => { type => Str, optional => 0 },
            list     => { type => Str, optional => 0 },
            password => { type => Str, optional => 0 },
            memo     => { type => Str, optional => 1 },
        },
    ),
    del => validation_for(
        params => {
            account => { type => Str, optional => 0 },
            list    => { type => Str, optional => 0 },
        },
    ),
    get => validation_for(
        params => {
            account => { type => Str, optional => 0 },
            list    => { type => Str, optional => 0 },
        },
    ),
    list => validation_for( params => { account => { type => Str, optional => 1 } } ),
    set => validation_for(
        params => {
            account  => { type => Str, optional => 0 },
            list     => { type => Str, optional => 0 },
            password => { type => Str, optional => 1 },
            memo     => { type => Str, optional => 1 },
        },
    ),
    add_member => validation_for(
        params => {
            account => { type => Str, optional => 0 },
            list    => { type => Str, optional => 0 },
            email   => { type => Str, optional => 0 },
        },
    ),
    del_member => validation_for(
        params => {
            account => { type => Str, optional => 0 },
            list    => { type => Str, optional => 0 },
            email   => { type => Str, optional => 0 },
        },
    ),
    list_members => validation_for(
        params => {
            account => { type => Str, optional => 0 },
            list    => { type => Str, optional => 0 },
        },
    ),
);

=method add

    $api->mailinglist->add(
        account  => 'admin@example.com',
        list     => 'list@example.com',
        password => 'secret',
        memo     => 'Optional note',
    );

Add a new mailing list. Required: C<account>, C<list>, C<password>.

=cut

sub add {
    my ( $self, %params ) = @_;
    my $v = $validators{'add'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'mailinglist.add', \%params );
}

=method del

    $api->mailinglist->del(
        account => 'admin@example.com',
        list    => 'list@example.com',
    );

Delete a mailing list.

=cut

sub del {
    my ( $self, %params ) = @_;
    my $v = $validators{'del'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'mailinglist.del', \%params );
}

=method get

    $api->mailinglist->get(
        account => 'admin@example.com',
        list    => 'list@example.com',
    );

Get mailing list details.

=cut

sub get {
    my ( $self, %params ) = @_;
    my $v = $validators{'get'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'mailinglist.get', \%params );
}

=method list

    $api->mailinglist->list;
    $api->mailinglist->list(account => 'admin@example.com');

List mailing lists. Optional C<account> filter.

=cut

sub list {
    my ( $self, %params ) = @_;
    my $v = $validators{'list'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'mailinglist.list', \%params );
}

=method set

    $api->mailinglist->set(
        account  => 'admin@example.com',
        list     => 'list@example.com',
        password => 'newsecret',
        memo     => 'Updated note',
    );

Update mailing list settings. At least C<account> and C<list> required.

=cut

sub set {
    my ( $self, %params ) = @_;
    my $v = $validators{'set'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'mailinglist.set', \%params );
}

=method add_member

    $api->mailinglist->add_member(
        account => 'admin@example.com',
        list    => 'list@example.com',
        email   => 'member@example.com',
    );

Add a member to a mailing list.

=cut

sub add_member {
    my ( $self, %params ) = @_;
    my $v = $validators{'add_member'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'mailinglist.add_member', \%params );
}

=method del_member

    $api->mailinglist->del_member(
        account => 'admin@example.com',
        list    => 'list@example.com',
        email   => 'member@example.com',
    );

Remove a member from a mailing list.

=cut

sub del_member {
    my ( $self, %params ) = @_;
    my $v = $validators{'del_member'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'mailinglist.del_member', \%params );
}

=method list_members

    $api->mailinglist->list_members(
        account => 'admin@example.com',
        list    => 'list@example.com',
    );

List all members of a mailing list.

=cut

sub list_members {
    my ( $self, %params ) = @_;
    my $v = $validators{'list_members'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'mailinglist.list_members', \%params );
}

1;
