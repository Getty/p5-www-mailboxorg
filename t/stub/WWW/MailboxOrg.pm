package WWW::MailboxOrg;

# ABSTRACT: Stub des Clients, damit der CLI-Test ohne Netzzugriff laeuft

use strict;
use warnings;

our $VERSION = '0.100';

sub new {
    my ( $class, %args ) = @_;
    return bless { %args }, $class;
}

sub account { return $_[0] }

sub list {
    return {
        accounts => [
            { account => 'user@example.com', active => 1 },
        ],
    };
}

1;
