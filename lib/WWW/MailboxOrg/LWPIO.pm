package WWW::MailboxOrg::LWPIO;

# ABSTRACT: Synchronous JSON-RPC backend using LWP::UserAgent

use Moo;
use LWP::UserAgent;
use HTTP::Request;
use WWW::MailboxOrg::JSONRPCRequest;
use WWW::MailboxOrg::JSONRPCResponse;
use JSON::MaybeXS qw(decode_json encode_json);

with 'WWW::MailboxOrg::Role::IO';

=head1 SYNOPSIS

    use WWW::MailboxOrg::LWPIO;

    my $io = WWW::MailboxOrg::LWPIO->new(timeout => 60);

=head1 DESCRIPTION

Default synchronous JSON-RPC backend using L<LWP::UserAgent>. Implements
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
        LWP::UserAgent->new(
            timeout => $self->timeout,
        );
    },
);

=attr ua

L<LWP::UserAgent> instance. Built lazily.

=cut

sub call {
    my ($self, $req) = @_;

    my $http_req = HTTP::Request->new(POST => $req->url);
    $http_req->header('Content-Type' => 'application/json');
    $http_req->header('HPLS-AUTH' => $req->headers->{'HPLS-AUTH'})
        if $req->headers && $req->headers->{'HPLS-AUTH'};

    $http_req->content(encode_json($req->to_hash));

    my $res = $self->ua->request($http_req);

    if (!$res->is_success) {
        return WWW::MailboxOrg::JSONRPCResponse->new(
            error => {
                code    => -32300,
                message => $res->status_line,
            },
            id => $req->id,
        );
    }

    my $data = eval { decode_json($res->decoded_content) };

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

Execute a L<WWW::MailboxOrg::JSONRPCRequest> via LWP::UserAgent and return a
L<WWW::MailboxOrg::JSONRPCResponse>.

=cut

1;

__END__

=head1 SEE ALSO

L<WWW::MailboxOrg::Role::IO>, L<WWW::MailboxOrg::Role::HTTP>,
L<LWP::UserAgent>

=cut
