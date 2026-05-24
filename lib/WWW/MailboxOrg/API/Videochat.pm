package WWW::MailboxOrg::API::Videochat;

# ABSTRACT: Video chat API

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
    status       => validation_for( params => { account => { type => Str, optional => 0 } } ),
    create_room  => validation_for(
        params => {
            account => { type => Str, optional => 0 },
            name    => { type => Str, optional => 0 },
        },
    ),
    list_rooms  => validation_for( params => { account => { type => Str, optional => 0 } } ),
    delete_room => validation_for(
        params => {
            account => { type => Str, optional => 0 },
            name    => { type => Str, optional => 0 },
        },
    ),
);

sub status {
    my ( $self, %params ) = @_;
    my $v = $validators{'status'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'videochat.status', \%params );
}

sub create_room {
    my ( $self, %params ) = @_;
    my $v = $validators{'create_room'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'videochat.create_room', \%params );
}

sub list_rooms {
    my ( $self, %params ) = @_;
    my $v = $validators{'list_rooms'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'videochat.list_rooms', \%params );
}

sub delete_room {
    my ( $self, %params ) = @_;
    my $v = $validators{'delete_room'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'videochat.delete_room', \%params );
}

1;

__END__

=head1 NAME

WWW::MailboxOrg::API::Videochat - Video chat API

=method status

    my $status = $api->videochat->status(account => 'admin@example.com');

Get video chat status. Required: C<account>.

=method create_room

    $api->videochat->create_room(
        account => 'admin@example.com',
        name    => 'My Room',
    );

Create a video chat room. Required: C<account>, C<name>.

=method list_rooms

    $api->videochat->list_rooms(account => 'admin@example.com');

List video chat rooms. Required: C<account>.

=method delete_room

    $api->videochat->delete_room(
        account => 'admin@example.com',
        name    => 'My Room',
    );

Delete a video chat room. Required: C<account>, C<name>.

=cut