package WWW::MailboxOrg::JSONRPCResponse;

# ABSTRACT: JSON-RPC 2.0 response object

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
    is       => 'ro',
    predicate => 'has_id',
);

=attr id

Request ID this response corresponds to.

=cut

sub is_success {
    my ($self) = @_;
    return $self->has_result && !$self->has_error;
}

=method is_success

Returns true if the response is successful.

=cut

1;