package WWW::MailboxOrg::API::Domain;

# ABSTRACT: Domain management API

use Moo;
with 'WWW::MailboxOrg::Role::API';
use Params::ValidationCompiler qw( validation_for );
use Types::Standard qw( Str Bool );
use WWW::MailboxOrg::Types qw( DomainName );

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

my %validators = (
    add => validation_for(
        params => {
            account               => { type => Str,       optional => 0 },
            domain               => { type => DomainName, optional => 0 },
            password             => { type => Str,       optional => 0 },
            context_id           => { type => Str,       optional => 1 },
            create_new_context_id => { type => Bool,      optional => 1 },
            memo                 => { type => Str,       optional => 1 },
        },
    ),
    del => validation_for(
        params => {
            account => { type => Str,       optional => 0 },
            domain  => { type => DomainName, optional => 0 },
        },
    ),
    get  => validation_for( params => { domain => { type => DomainName, optional => 0 } } ),
    list => validation_for(
        params => {
            account => { type => Str, optional => 1 },
            filter  => { type => Str, optional => 1 },
        },
    ),
    set => validation_for(
        params => {
            domain                => { type => DomainName, optional => 0 },
            password              => { type => Str, optional => 1 },
            context_id            => { type => Str, optional => 1 },
            create_new_context_id => { type => Bool, optional => 1 },
            memo                  => { type => Str, optional => 1 },
        },
    ),
);

=method add

    $api->domain->add(
        account               => 'admin@example.com',
        domain               => 'example.com',
        password             => 'secret123',
        context_id           => 'optional-context-id',
        create_new_context_id => 1,
        memo                 => 'Optional note',
    );

Add a new domain. Required: C<account>, C<domain>, C<password>.

=cut

sub add {
    my ( $self, %params ) = @_;
    my $v = $validators{'add'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'domain.add', \%params );
}

=method del

    $api->domain->del(
        account => 'admin@example.com',
        domain  => 'example.com',
    );

Delete a domain.

=cut

sub del {
    my ( $self, %params ) = @_;
    my $v = $validators{'del'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'domain.del', \%params );
}

=method get

    $api->domain->get(domain => 'example.com');

Get domain details.

=cut

sub get {
    my ( $self, %params ) = @_;
    my $v = $validators{'get'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'domain.get', \%params );
}

=method list

    $api->domain->list;
    $api->domain->list(account => 'admin@example.com');

List domains. Optional C<account> or C<filter>.

=cut

sub list {
    my ( $self, %params ) = @_;
    my $v = $validators{'list'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'domain.list', \%params );
}

=method set

    $api->domain->set(
        domain                => 'example.com',
        password              => 'newsecret',
        context_id            => 'new-context-id',
        create_new_context_id => 1,
        memo                  => 'Updated note',
    );

Update domain settings. At least C<domain> required.

=cut

sub set {
    my ( $self, %params ) = @_;
    my $v = $validators{'set'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'domain.set', \%params );
}

1;
