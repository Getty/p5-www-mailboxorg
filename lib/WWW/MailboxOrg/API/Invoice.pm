package WWW::MailboxOrg::API::Invoice;

# ABSTRACT: Invoice API

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
    list     => validation_for( params => { account => { type => Str, optional => 1 } } ),
    get      => validation_for(
        params => {
            account => { type => Str, optional => 0 },
            invoice => { type => Str, optional => 0 },
        },
    ),
    download => validation_for(
        params => {
            account => { type => Str, optional => 0 },
            invoice => { type => Str, optional => 0 },
        },
    ),
);

=method list

    my $invoices = $api->invoice->list;
    $api->invoice->list(account => 'admin@example.com');

List invoices. Optional C<account> filter.

=cut

sub list {
    my ( $self, %params ) = @_;
    my $v = $validators{'list'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'invoice.list', \%params );
}

=method get

    $api->invoice->get(
        account => 'admin@example.com',
        invoice => 'INV-2024-001',
    );

Get invoice details. Required: C<account>, C<invoice>.

=cut

sub get {
    my ( $self, %params ) = @_;
    my $v = $validators{'get'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'invoice.get', \%params );
}

=method download

    $api->invoice->download(
        account => 'admin@example.com',
        invoice => 'INV-2024-001',
    );

Download an invoice. Required: C<account>, C<invoice>.

=cut

sub download {
    my ( $self, %params ) = @_;
    my $v = $validators{'download'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'invoice.download', \%params );
}

1;
