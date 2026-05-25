package WWW::MailboxOrg::API::Account;

# ABSTRACT: Account management API

use Moo;
with 'WWW::MailboxOrg::Role::API';
use Params::ValidationCompiler qw( validation_for );
use Types::Standard qw( Str Enum HashRef );
use WWW::MailboxOrg::Types qw( EmailAddress );

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

my %validators = (
    add => validation_for(
        params => {
            account      => { type => EmailAddress, optional => 0 },
            password     => { type => Str, optional => 0 },
            plan         => { type => Enum [qw( basic profi profixl reseller )], optional => 0 },
            tarifflimits => { type => HashRef, optional => 1 },
            memo         => { type => Str, optional => 1 },
        },
    ),
    del => validation_for( params => { account => { type => EmailAddress, optional => 0 } } ),
    get => validation_for( params => { account => { type => EmailAddress, optional => 0 } } ),
    list => validation_for( params => { account => { type => EmailAddress, optional => 1 } } ),
    set => validation_for(
        params => {
            account                    => { type => EmailAddress, optional => 0 },
            password                   => { type => Str, optional => 1 },
            plan                       => { type => Enum [qw( basic profi profixl reseller )], optional => 1 },
            memo                       => { type => Str, optional => 1 },
            address_payment_first_name => { type => Str, optional => 1 },
            address_payment_last_name  => { type => Str, optional => 1 },
            address_payment_street     => { type => Str, optional => 1 },
            address_payment_zipcode    => { type => Str, optional => 1 },
            address_payment_town       => { type => Str, optional => 1 },
            av_contract_accept_name    => { type => Str, optional => 1 },
            tarifflimits               => { type => HashRef, optional => 1 },
        },
    ),
);

=method add

    $api->account->add(
        account      => 'user@example.com',
        password     => 'secret123',
        plan         => 'basic',
        tarifflimits => { ... },
        memo         => 'Optional note',
    );

Add a new account. Required: C<account>, C<password>, C<plan>.

=cut

sub add {
    my ( $self, %params ) = @_;
    my $v = $validators{'add'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'account.add', \%params );
}

=method del

    $api->account->del(account => 'user@example.com');

Delete an account.

=cut

sub del {
    my ( $self, %params ) = @_;
    my $v = $validators{'del'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'account.del', \%params );
}

=method get

    $api->account->get(account => 'user@example.com');

Get account details.

=cut

sub get {
    my ( $self, %params ) = @_;
    my $v = $validators{'get'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'account.get', \%params );
}

=method list

    $api->account->list;
    $api->account->list(account => 'admin@example.com');

List accounts. Optional C<account> filter.

=cut

sub list {
    my ( $self, %params ) = @_;
    my $v = $validators{'list'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'account.list', \%params );
}

=method set

    $api->account->set(
        account => 'user@example.com',
        plan    => 'profi',
        memo    => 'Updated note',
    );

Update account settings. At least C<account> required.

=cut

sub set {
    my ( $self, %params ) = @_;
    my $v = $validators{'set'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'account.set', \%params );
}

1;
