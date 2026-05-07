package WWW::MailboxOrg::LWPIO;

# ABSTRACT: Synchronous JSON-RPC backend using Mojo::UserAgent

use Moo;
use Mojo::UserAgent;
use WWW::MailboxOrg::JSONRPCRequest;
use WWW::MailboxOrg::JSONRPCResponse;
use JSON::MaybeXS qw(decode_json encode_json);

with 'WWW::MailboxOrg::Role::IO';

our $VERSION = '0.002';

=head1 SYNOPSIS

    use WWW::MailboxOrg::LWPIO;

    my $io = WWW::MailboxOrg::LWPIO->new(timeout => 60);

=head1 DESCRIPTION

Default synchronous JSON-RPC backend using L<Mojo::UserAgent>. Implements
L<WWW::MailboxOrg::Role::IO>.

=cut

has timeout => (
    is      => 'ro',
    default => 30,
);

=attr timeout

Timeout in seconds for HTTP requests. Defaults to 30.

=cut

has ua => (
    is      => 'lazy',
    builder => sub {
        my ($self) = @_;
        Mojo::UserAgent->new(
            timeout => $self->timeout,
        );
    },
);

=attr ua

L<Mojo::UserAgent> instance. Built lazily.

=cut

sub call {
    my ($self, $req) = @_;

    my $url = $req->url;

    my %headers = (
        'Content-Type' => 'application/json',
    );
    $headers{'HPLS-AUTH'} = $req->headers->{'HPLS-AUTH'}
        if $req->headers && $req->headers->{'HPLS-AUTH'};

    my $payload = encode_json($req->to_hash);

    my $tx = $self->ua->post($url, \%headers, json => $req->to_hash);

    if (my $err = $tx->error) {
        return WWW::MailboxOrg::JSONRPCResponse->new(
            error => {
                code    => -32300,
                message => $err->{message},
            },
            id => $req->id,
        );
    }

    my $data = $tx->res->json;

    if (!$data) {
        return WWW::MailboxOrg::JSONRPCResponse->new(
            error => {
                code    => -32603,
                message => 'Empty or invalid JSON response',
            },
            id => $req->id,
        );
    }

    return WWW::MailboxOrg::JSONRPCResponse->new(%$data);
}

=method call($req)

Execute a L<WWW::MailboxOrg::JSONRPCRequest> via Mojo::UserAgent and return a
L<WWW::MailboxOrg::JSONRPCResponse>.

=cut

1;

__END__

=head1 SEE ALSO

L<WWW::MailboxOrg::Role::IO>, L<WWW::MailboxOrg::Role::HTTP>,
L<Mojo::UserAgent>

=cut