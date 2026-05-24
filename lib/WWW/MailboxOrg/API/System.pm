package WWW::MailboxOrg::API::System;

# ABSTRACT: System API (hello, test, capabilities)

use Moo;
with 'WWW::MailboxOrg::Role::API';

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

=method hello

    my $result = $api->system->hello;

Get API hello response. No parameters required.

=cut

sub hello       { shift->_rpc('hello') }

=method test

    my $result = $api->system->test;

Test API connection. Returns test result.

=cut

sub test        { shift->_rpc('test') }

=method capabilities

    my $caps = $api->system->capabilities;

Get API capabilities. Returns capability list.

=cut

sub capabilities { shift->_rpc('capabilities') }

1;

__END__

=head1 NAME

WWW::MailboxOrg::API::System - System API (hello, test, capabilities)

=cut