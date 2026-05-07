package WWW::MailboxOrg::Entity::Domain;

# ABSTRACT: Domain entity object

use Moo;

our $VERSION = '0.002';

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has domain => (
    is       => 'ro',
    required => 1,
);

=attr domain

Domain name.

=cut

has context_id => (
    is       => 'ro',
    predicate => 'has_context_id',
);

=attr context_id

Context ID.

=cut

has is_active => (
    is       => 'ro',
    predicate => 'has_is_active',
);

=attr is_active

Whether the domain is active.

=cut

has data => (
    is       => 'ro',
    builder  => '_build_data',
);

sub _build_data {
    my ($self) = @_;
    return {
        domain     => $self->domain,
        context_id => $self->context_id,
        is_active  => $self->is_active,
    };
}

=method data

Returns a hashref of the entity data.

=cut

1;

__END__

=head1 NAME

WWW::MailboxOrg::Entity::Domain - Domain entity object

=head1 SEE ALSO

L<WWW::MailboxOrg>

=cut