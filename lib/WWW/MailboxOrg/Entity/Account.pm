package WWW::MailboxOrg::Entity::Account;

# ABSTRACT: Account entity object

use Moo;

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has account => (
    is       => 'ro',
    required => 1,
);

=attr account

Account email address.

=cut

has plan => (
    is       => 'ro',
    predicate => 'has_plan',
);

=attr plan

Account plan: basic, profi, profixl, reseller.

=cut

has confirmed => (
    is       => 'ro',
    predicate => 'has_confirmed',
);

=attr confirmed

Account confirmation status.

=cut

has is_active => (
    is       => 'ro',
    predicate => 'has_is_active',
);

=attr is_active

Whether the account is active.

=cut

has is_locked => (
    is       => 'ro',
    predicate => 'has_is_locked',
);

=attr is_locked

Whether the account is locked.

=cut

has data => (
    is       => 'ro',
    builder  => '_build_data',
);

sub _build_data {
    my ($self) = @_;
    return {
        account   => $self->account,
        plan      => $self->plan,
        confirmed => $self->confirmed,
        is_active => $self->is_active,
        is_locked => $self->is_locked,
    };
}

=method data

Returns a hashref of the entity data.

=cut

1;

__END__

=head1 NAME

WWW::MailboxOrg::Entity::Account - Account entity object

=head1 SEE ALSO

L<WWW::MailboxOrg>

=cut