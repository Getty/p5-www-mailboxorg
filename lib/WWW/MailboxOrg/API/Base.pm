package WWW::MailboxOrg::API::Base;

# ABSTRACT: Base API controller for auth and search

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
    auth   => validation_for( params => { user => { type => Str, optional => 0 }, pass => { type => Str, optional => 0 } } ),
    search => validation_for( params => { query => { type => Str, optional => 0 } } ),
);

=method auth

    $api->base->auth(user => 'user@example.com', pass => 'secret');

Authenticate and get session token. Required: C<user>, C<pass>.

=cut

sub auth {
    my ( $self, %params ) = @_;
    my $v = $validators{'auth'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'auth', \%params );
}

=method deauth

    $api->base->deauth;

End the current session.

=cut

sub deauth {
    my ( $self ) = @_;
    return $self->_rpc('deauth');
}

=method search

    my $results = $api->base->search(query => 'some search terms');

Search across the API. Required: C<query>.

=cut

sub search {
    my ( $self, %params ) = @_;
    my $v = $validators{'search'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'search', \%params );
}

1;

__END__

=head1 NAME

WWW::MailboxOrg::API::Base - Base API controller for auth and search

=cut