package WWW::MailboxOrg::API::Spamprotect;

# ABSTRACT: Spam protection API

use Moo;
use MooX::Singleton;
use Carp qw(croak);
use Params::ValidationCompiler qw(validation_for);
use Types::Standard qw(Str Bool);

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

sub status {
    my ($self, %params) = @_;
    my $v = $validators{'status'};
    %params = $v->(%params) if $v;
    return $self->_rpc('spamprotect.status', \%params);
}

sub set {
    my ($self, %params) = @_;
    my $v = $validators{'set'};
    %params = $v->(%params) if $v;
    return $self->_rpc('spamprotect.set', \%params);
}

1;

__END__

=head1 NAME

WWW::MailboxOrg::API::Spamprotect - Spam protection API


=method status

    my $status = $api->spamprotect->status(account => 'admin@example.com');

Get spam protection status. Required: C<account>.

=method set

    $api->spamprotect->set(
        account => 'admin@example.com',
        active  => 1,
    );

Enable or disable spam protection. Required: C<account>, C<active>.

=cut