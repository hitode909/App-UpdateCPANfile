use strict;
use Test2::V0;

use App::UpdateCPANfile::Change;

subtest 'instantiate' => sub {
    my $change = App::UpdateCPANfile::Change->new(
        package_name => 'Unicode::GCString',
        version => '2013.10',
        version_from => '2012.10',
        path => 'N/NE/NEZUMI/Unicode-LineBreak-2019.001.tar.gz',
    );
    is $change, object {
        call package_name => 'Unicode::GCString';
        call version => '2013.10';
        call version_from => '2012.10';
        call path => 'N/NE/NEZUMI/Unicode-LineBreak-2019.001.tar.gz';
        call dist_name => 'Unicode-LineBreak';
    };

    is $change->prereqs, [
        ['Unicode::GCString' => '== 2013.10'],
        ['Unicode::GCString' => '== 2013.10', relationship => 'suggests'],
        ['Unicode::GCString' => '== 2013.10', relationship => 'recommends'],
    ];

    is $change->as_hashref, {
        package_name => 'Unicode::GCString',
        version      => '2013.10',
        version_from => '2012.10',
        path         => 'N/NE/NEZUMI/Unicode-LineBreak-2019.001.tar.gz',
        dist_name    => 'Unicode-LineBreak',
    };
};

done_testing;

