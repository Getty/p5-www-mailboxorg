use strict;
use warnings;

use Test::More;

use Path::Tiny;

# Die cpanfile ist die Quelle der Prerequisites. Sie listet sie alphabetisch
# und pinnt eine echte Mindestversion nur dort, wo der Code sie braucht - ein
# leerer Pin ('0') wäre kein Pin.

my $cpanfile = Path::Tiny->new( 'cpanfile' );

plan skip_all => 'cpanfile is not part of the distribution' unless $cpanfile->is_file;

my %requires;
my @runtime_order;
my $phase = 'runtime';

for my $line ( $cpanfile->lines ) {
    next if $line =~ /^\s*#/;
    if ( $line =~ /^\s*on\s+(\w+)\s*=>\s*sub\s*\{/ ) {
        $phase = $1;
        next;
    }
    next unless $line =~ /^\s*requires\s+'([^']+)'\s*(?:=>\s*'([^']*)')?\s*;/;
    my ( $module, $version ) = ( $1, $2 );
    $requires{$phase}{$module} = defined $version ? $version : '';
    push @runtime_order, $module if $phase eq 'runtime';
}

my @expected_runtime = qw(
  Carp
  File::HomeDir
  Getopt::Long::Descriptive
  HTTP::Request
  JSON::MaybeXS
  Log::Any
  LWP::Protocol::https
  LWP::UserAgent
  Moo
  MooX::Singleton
  namespace::clean
  Params::ValidationCompiler
  Path::Tiny
  Pod::Usage
  Type::Library
  Type::Utils
  Types::Standard
);

# Die cpanfile sortiert case-insensitiv, sonst stuende LWP::Protocol::https
# vor Log::Any.
sub sort_modules { sort { lc $a cmp lc $b } @_ }

subtest 'Die Laufzeit-Prerequisites sind vollständig' => sub {
  is_deeply(
    [ sort_modules( keys %{ $requires{runtime} || {} } ) ],
    [ sort_modules(@expected_runtime) ],
    'die Laufzeit-Prerequisites stimmen'
  );
};

subtest 'Die Laufzeit-Prerequisites stehen alphabetisch' => sub {
  is_deeply( \@runtime_order, \@expected_runtime, 'die Reihenfolge ist alphabetisch' );
};

subtest 'Kein Prerequisite pinnt eine leere Version' => sub {
  for my $module ( keys %{ $requires{runtime} || {} } ) {
    isnt( $requires{runtime}{$module}, '0', "$module pinnt keine leere Version" );
  }
  for my $module ( keys %{ $requires{test} || {} } ) {
    isnt( $requires{test}{$module}, '0', "$module pinnt keine leere Version" );
  }
};

subtest 'Die Mindestversionen bleiben gepinnt' => sub {
  is( $requires{runtime}{Moo},                '1.006', 'Moo bleibt bei 1.006' );
  is( $requires{runtime}{'Type::Library'},   '1.012', 'Type::Library bleibt bei 1.012' );
  is( $requires{runtime}{'Type::Utils'},     '1.012', 'Type::Utils bleibt bei 1.012' );
  is( $requires{runtime}{'Types::Standard'}, '1.012', 'Types::Standard bleibt bei 1.012' );
  is( $requires{develop}{'Dist::Zilla'},     '6.017', 'Dist::Zilla bleibt bei 6.017' );
};

subtest 'Die Test-Phase trägt ihre Prerequisites' => sub {
  is_deeply(
    [ sort keys %{ $requires{test} || {} } ],
    [ 'Test::Exception', 'Test::More' ],
    'die Test-Prerequisites stimmen'
  );
};

done_testing;
