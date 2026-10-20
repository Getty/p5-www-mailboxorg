use strict;
use warnings;

use Test::More;
use JSON::MaybeXS qw( decode_json );

my $script = 'bin/mborg';
my $user   = 'test@example.com';

subtest 'bin/mborg kompiliert' => sub {
    my $output = qx{$^X -Ilib -c $script 2>&1};
    is( $?, 0, 'perl -c meldet keinen Fehler' ) or diag $output;
    like( $output, qr/syntax OK/, 'Syntaxpruefung bestanden' );
};

subtest 'pp gibt das API-Ergebnis als JSON aus' => sub {
    my $output = qx{$^X -It/stub -Ilib $script --user=$user --password=secret account list 2>&1};
    is( $?, 0, 'mborg beendet sich ohne Fehler' ) or diag $output;

    my $data = eval { decode_json($output) };
    ok( !$@, 'Ausgabe ist gueltiges JSON' ) or diag $output;

    is_deeply(
        $data,
        { accounts => [ { account => 'user@example.com', active => 1 } ] },
        'API-Ergebnis wird vollstaendig ausgegeben',
    );
};

done_testing;
