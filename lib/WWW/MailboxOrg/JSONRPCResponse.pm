package WWW::MailboxOrg::JSONRPCResponse;

# ABSTRACT: JSON-RPC 2.0 response object

our $VERSION = '0.101';

use Moo;

=head1 SYNOPSIS

    use WWW::MailboxOrg::JSONRPCResponse;

    my $res = WWW::MailboxOrg::JSONRPCResponse->new(
        result => { account => 'test@example.tld' },
        id     => 1,
    );

=head1 DESCRIPTION

JSON-RPC 2.0 response object.

=cut

has result => (
    is       => 'ro',
    predicate => 'has_result',
);

=attr result

The response result (absent on error).

=cut

has error => (
    is       => 'ro',
    predicate => 'has_error',
);

=attr error

Error object with C<code> and C<message> keys.

=cut

has id => (
    is => 'ro',
);

=attr id

Request ID this response corresponds to. A response without an id or with a
null id has none, so C<has_id> is false for it.

=cut

# Value-based, not existence-based: Moo would report a response as having an
# id as soon as the key exists, but a response may carry a null id.
sub has_id {
    my ($self) = @_;
    return defined $self->{id};
}

sub is_success {
    my ($self) = @_;
    return $self->has_result && !$self->has_error;
}

=method is_success

Returns true if the response is successful.

=cut

1;