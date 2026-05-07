package WWW::MailboxOrg::API::Utils;

# ABSTRACT: Utility API (parse_headers, parse_date, generate_message_id)

use Moo;
use MooX::Singleton;
use Carp qw(croak);
use Params::ValidationCompiler qw(validation_for);
use Types::Standard qw(Str HashRef);

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
    parse_headers => validation_for(
        params => {
            headers => { type => Str, optional => 0 },
        },
    ),
    parse_date => validation_for(
        params => {
            date => { type => Str, optional => 0 },
        },
    ),
    generate_message_id => validation_for(
        params => {
            account => { type => Str, optional => 0 },
        },
    ),
);

sub parse_headers {
    my ($self, %params) = @_;
    my $v = $validators{'parse_headers'};
    %params = $v->(%params) if $v;
    return $self->_rpc('utils.parse_headers', \%params);
}

sub parse_date {
    my ($self, %params) = @_;
    my $v = $validators{'parse_date'};
    %params = $v->(%params) if $v;
    return $self->_rpc('utils.parse_date', \%params);
}

sub generate_message_id {
    my ($self, %params) = @_;
    my $v = $validators{'generate_message_id'};
    %params = $v->(%params) if $v;
    return $self->_rpc('utils.generate_message_id', \%params);
}

1;

__END__

=head1 NAME

WWW::MailboxOrg::API::Utils - Utility API


=method parse_headers

    my $parsed = $api->utils->parse_headers(
        headers => "From: user@example.com\r\nSubject: Hello",
    );

Parse email headers. Required: C<headers>.

=method parse_date

    my $parsed = $api->utils->parse_date(date => 'Mon, 01 Jan 2024 12:00:00 +0000');

Parse an email date. Required: C<date>.

=method generate_message_id

    my $msg_id = $api->utils->generate_message_id;
    my $msg_id = $api->utils->generate_message_id(account => 'user@example.com');

Generate a message ID. Optional: C<account>.

=cut