package WWW::MailboxOrg::Types;

# ABSTRACT: Custom types for Mailbox.org API

use Type::Library -base, -declare => qw( EmailAddress DomainName );
use Type::Utils -all;
use Types::Standard -types;

our $VERSION = '0.002';

my $meta = __PACKAGE__->meta;

declare EmailAddress,
    as Str,
    where { /^[^\s@]+@[^\s@]+\.[^\s@]+$/ },
    message { "$_ is not a valid email address" };

declare DomainName,
    as Str,
    where { /^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$/ },
    message { "$_ is not a valid domain name" };

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SYNOPSIS

    use WWW::MailboxOrg::Types qw( EmailAddress DomainName );

    has email => ( is => 'ro', isa => EmailAddress );
    has domain => ( is => 'ro', isa => DomainName );

=head1 TYPES

=func EmailAddress

Valid email address format.

=func DomainName

Valid domain name format.

=cut