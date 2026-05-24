package WWW::MailboxOrg::JSONRPCRequest;

# ABSTRACT: JSON-RPC 2.0 request object

use Moo;

=head1 SYNOPSIS

    use WWW::MailboxOrg::JSONRPCRequest;

    my $req = WWW::MailboxOrg::JSONRPCRequest->new(
        method => 'account.get',
        params => { account => 'test@example.tld' },
        id     => 1,
        url    => 'https://api.mailbox.org/v1',
        headers => { 'HPLS-AUTH' => 'session123' },
    );

=head1 DESCRIPTION

Transport-independent JSON-RPC 2.0 request object.

=cut

has jsonrpc => (
    is      => 'ro',
    default => '2.0',
);

=attr jsonrpc

JSON-RPC version. Defaults to "2.0".

=cut

has method => (
    is       => 'ro',
    required => 1,
);

=attr method

The RPC method name, e.g. "account.get".

=cut

has params => (
    is      => 'ro',
    default => sub { [] },
);

=attr params

ArrayRef of positional parameters or HashRef of named parameters.

=cut

has id => (
    is       => 'ro',
    predicate => 'has_id',
);

=attr id

Request ID for correlating responses. Undef for notifications.

=cut

has url => (
    is       => 'ro',
    required => 1,
);

=attr url

The endpoint URL for the request.

=cut

has headers => (
    is      => 'ro',
    default => sub { {} },
);

=attr headers

Hashref of HTTP headers (e.g. HPLS-AUTH).

=cut

sub to_hash {
    my ($self) = @_;
    my %hash = (
        jsonrpc => $self->jsonrpc,
        method  => $self->method,
        id      => $self->id,
    );
    my $params = $self->params;
    $hash{params} = $params if $params && (ref($params) eq 'ARRAY' ? @$params : %$params);
    return \%hash;
}

=method to_hash

Returns a hashref representation for JSON encoding.

=cut

1;