# ABSTRACT: Perl client for Mailbox.org API

use strict;
use warnings;

requires 'Carp';
requires 'File::HomeDir';
requires 'Getopt::Long::Descriptive';
requires 'HTTP::Request';
requires 'JSON::MaybeXS';
requires 'Log::Any';
requires 'LWP::Protocol::https';
requires 'LWP::UserAgent';
requires 'Moo' => '1.006';
requires 'MooX::Singleton';
requires 'namespace::clean';
requires 'Params::ValidationCompiler';
requires 'Path::Tiny';
requires 'Pod::Usage';
requires 'Type::Library' => '1.012';
requires 'Type::Utils' => '1.012';
requires 'Types::Standard' => '1.012';

on test => sub {
    requires 'Test::Exception';
    requires 'Test::More';
};

on develop => sub {
    requires 'Dist::Zilla' => '6.017';
};
