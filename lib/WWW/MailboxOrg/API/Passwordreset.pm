package WWW::MailboxOrg::API::Passwordreset;

# ABSTRACT: Password reset API

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
    request => validation_for(
        params => {
            account => { type => Str, optional => 0 },
        },
    ),
    set => validation_for(
        params => {
            account     => { type => Str, optional => 0 },
            token       => { type => Str, optional => 0 },
            newpassword => { type => Str, optional => 0 },
        },
    ),
);

=method request

    $api->passwordreset->request(account => 'user@example.com');

Request password reset. Required: C<account>.

=cut

sub request {
    my ( $self, %params ) = @_;
    my $v = $validators{'request'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'passwordreset.request', \%params );
}

=method set

    $api->passwordreset->set(
        account     => 'user@example.com',
        token       => 'reset-token-from-email',
        newpassword => 'newsecret123',
    );

Set new password. Required: C<account>, C<token>, C<newpassword>.

=cut

sub set {
    my ( $self, %params ) = @_;
    my $v = $validators{'set'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'passwordreset.set', \%params );
}

1;
