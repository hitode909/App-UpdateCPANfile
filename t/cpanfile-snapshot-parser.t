use strict;
use Test2::V0;

use App::UpdateCPANfile::CPANfileSnapshotParser;

subtest 'parse' => sub {
    my $deps = App::UpdateCPANfile::CPANfileSnapshotParser->scan_deps('t/fixtures/simple/cpanfile.snapshot');
    is $deps, [
        object { call pathname => "H/HA/HAARG/MRO-Compat-0.13.tar.gz"; },
        object { call pathname => "L/LE/LEONT/Module-Build-0.4231.tar.gz"; },
        object { call pathname => "M/MI/MIYAGAWA/Module-CPANfile-1.1003.tar.gz"; },
        object { call pathname => "Z/ZE/ZEFRAM/Module-Runtime-0.016.tar.gz"; },
        object { call pathname => "E/ET/ETHER/Test-Class-0.49.tar.gz"; },
        object { call pathname => "E/EX/EXODIST/Test-Simple-1.302175.tar.gz"; },
        object { call pathname => "E/ET/ETHER/Try-Tiny-0.30.tar.gz"; },
    ];
};

done_testing;

