package WWW::MailboxOrg::API::Spamprotect;

# ABSTRACT: Spam protection API

use Moo;
with 'WWW::MailboxOrg::Role::API';
use Params::ValidationCompiler qw( validation_for );
use Types::Standard qw( Str Bool );

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

my %validators = (
    status => validation_for(
        params => {
            account => { type => Str, optional => 0 },
        },
    ),
    set => validation_for(
        params => {
            account => { type => Str, optional => 0 },
            active  => { type => Bool, optional => 0 },
        },
    ),
);

=method status

    my $status = $api->spamprotect->status(account => 'admin@example.com');

Get spam protection status. Required: C<account>.

=cut

sub status {
    my ( $self, %params ) = @_;
    my $v = $validators{'status'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'spamprotect.status', \%params );
}

=method set

    $api->spamprotect->set(
        account => 'admin@example.com',
        active  => 1,
    );

Enable or disable spam protection. Required: C<account>, C<active>.

=cut

sub set {
    my ( $self, %params ) = @_;
    my $v = $validators{'set'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'spamprotect.set', \%params );
}

1;
