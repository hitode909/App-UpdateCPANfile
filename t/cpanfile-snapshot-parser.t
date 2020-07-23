use strict;
use Test::More 0.98;

use App::UpdateCPANfile::CPANfileSnapshotParser;

subtest 'parse' => sub {
    my $deps = App::UpdateCPANfile::CPANfileSnapshotParser->scan_deps('t/fixtures/simple/cpanfile.snapshot');
    is_deeply $deps, [
        "H/HA/HAARG/MRO-Compat-0.13.tar.gz",
        "L/LE/LEONT/Module-Build-0.4231.tar.gz",
        "M/MI/MIYAGAWA/Module-CPANfile-1.1004.tar.gz",
        "Z/ZE/ZEFRAM/Module-Runtime-0.016.tar.gz",
        "E/ET/ETHER/Test-Class-0.50.tar.gz",
        "E/EX/EXODIST/Test-Simple-1.302175.tar.gz",
        "E/ET/ETHER/Try-Tiny-0.30.tar.gz"
    ];
};

done_testing;

