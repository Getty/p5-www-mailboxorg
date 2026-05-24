package WWW::MailboxOrg::API::Backup;

# ABSTRACT: Backup API

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
    list    => validation_for( params => { account => { type => Str, optional => 0 } } ),
    create  => validation_for( params => { account => { type => Str, optional => 0 } } ),
    restore => validation_for(
        params => {
            account => { type => Str, optional => 0 },
            backup  => { type => Str, optional => 0 },
        },
    ),
    delete => validation_for(
        params => {
            account => { type => Str, optional => 0 },
            backup  => { type => Str, optional => 0 },
        },
    ),
);

=method list

    my $backups = $api->backup->list(account => 'admin@example.com');

List backups. Required: C<account>.

=cut

sub list {
    my ( $self, %params ) = @_;
    my $v = $validators{'list'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'backup.list', \%params );
}

=method create

    $api->backup->create(account => 'admin@example.com');

Create a backup. Required: C<account>.

=cut

sub create {
    my ( $self, %params ) = @_;
    my $v = $validators{'create'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'backup.create', \%params );
}

=method restore

    $api->backup->restore(
        account => 'admin@example.com',
        backup  => 'backup-id',
    );

Restore a backup. Required: C<account>, C<backup>.

=cut

sub restore {
    my ( $self, %params ) = @_;
    my $v = $validators{'restore'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'backup.restore', \%params );
}

=method delete

    $api->backup->delete(
        account => 'admin@example.com',
        backup  => 'backup-id',
    );

Delete a backup. Required: C<account>, C<backup>.

=cut

sub delete {
    my ( $self, %params ) = @_;
    my $v = $validators{'delete'};
    %params = $v->(%params) if $v;
    return $self->_rpc( 'backup.delete', \%params );
}

1;

__END__

=head1 NAME

WWW::MailboxOrg::API::Backup - Backup API

=cut