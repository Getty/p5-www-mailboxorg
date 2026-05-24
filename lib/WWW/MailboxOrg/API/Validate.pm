package WWW::MailboxOrg::API::Validate;

# ABSTRACT: Validation API

use Moo;
with 'WWW::MailboxOrg::Role::API';
use Params::ValidationCompiler qw( validation_for );
use Types::Standard qw(Str);

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

my %validators = (
    email => validation_for(
        params => {
            email => { type => Str, optional => 0 },
        },
    ),
);

sub email {
    my ( $self, %params ) = @_;
    my $v = $validators{'email'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'validate.email', \%params );
}

1;

__END__

=head1 NAME

WWW::MailboxOrg::API::Validate - Validation API

=method email

    my $result = $api->validate->email(email => 'user@example.com');

Validate an email address. Required: C<email>.

=cut