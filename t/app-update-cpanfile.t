use strict;
use Test2::V0;
use lib '.';

use App::UpdateCPANfile;
use t::lib::SetupFixture;
use Test::WWW::Stub;
use Path::Class qw(file);

my $stubbed_res = [ 200, [], [file('t/fixtures/02packages/02packages.details.txt.gz')->slurp] ];
my $guard = Test::WWW::Stub->register(qr<http://.+>, $stubbed_res);

subtest 'initialize' => sub {
    my $app = App::UpdateCPANfile->new('my.cpanfile', 'my.cpanfile.snapshot');
    isa_ok $app, 'App::UpdateCPANfile';
    is $app->path, 'my.cpanfile';
    is $app->snapshot_path, 'my.cpanfile.snapshot';
    is $app->options, {};
};

subtest 'initialize with options' => sub {
    my $app = App::UpdateCPANfile->new('my.cpanfile', 'my.cpanfile.snapshot', { limit => 3, filter => 'foo', 'ignore-filter' => 'bar'});
    isa_ok $app, 'App::UpdateCPANfile';
    is $app->path, 'my.cpanfile';
    is $app->snapshot_path, 'my.cpanfile.snapshot';
    is $app->options, { limit => 3, filter => 'foo', 'ignore-filter' => 'bar'};
};

subtest 'initialize without path' => sub {
    my $app = App::UpdateCPANfile->new;
    is $app->path, 'cpanfile';
    is $app->snapshot_path, 'cpanfile.snapshot';
};

subtest 'it parses cpanfile' => sub {
    my $app = App::UpdateCPANfile->new;
    isa_ok $app->parser, 'Module::CPANfile';
    isa_ok $app->writer, 'Module::CPANfile::Writer';
};

subtest 'it holds package_details' => sub {
    my $app = App::UpdateCPANfile->new;
    isa_ok $app->package_details, 'App::UpdateCPANfile::PackageDetails';
};

subtest 'it creates changeset for pin dependencies' => sub {
    my $app = App::UpdateCPANfile->new('t/fixtures/simple/cpanfile', 't/fixtures/simple/cpanfile.snapshot');

    my $pin = $app->create_pin_dependencies_changeset;
    is $pin, [
        [
            "Module::CPANfile",
            "== 1.1003"
        ],
        [
            "Test::Class",
            "== 0.49",
        ],
    ];
};

subtest 'all phases are supported' => sub {
    my $app = App::UpdateCPANfile->new('t/fixtures/custom_phase/cpanfile', 't/fixtures/custom_phase/cpanfile.snapshot');

    my $pin = $app->create_pin_dependencies_changeset;
    is $pin, [
        [
            "Module::CPANfile",
            "== 1.1003"
        ],
        [
            "Test::Class",
            "== 0.49",
        ],
    ];
};

subtest 'it converts suggests too' => sub {
    my $app = App::UpdateCPANfile->new('t/fixtures/suggests/cpanfile', 't/fixtures/suggests/cpanfile.snapshot');

    my $pin = $app->create_pin_dependencies_changeset;
    is $pin, [
        [
            "Module::CPANfile",
            "== 1.1003"
        ],
        [
            "Test::Class",
            "== 0.49",
        ],
    ];
};

subtest "it writes suggests, recommends to cpanfile. It doesn't write conflicts" => sub {
    my $dir = t::lib::SetupFixture::prepare_test_code('suggests');
    my $app = App::UpdateCPANfile->new("$dir/cpanfile", "$dir/cpanfile.snapshot");

    my $pin = $app->pin_dependencies;
    is $pin, [
        [
            "Module::CPANfile",
            "== 1.1003"
        ],
        [
            "Test::Class",
            "== 0.49",
        ],
    ], 'it returns changeset';


    my $saved_content = file("$dir/cpanfile")->slurp;
    is $saved_content, <<CPANFILE;
suggests 'Module::CPANfile', '== 1.1003';
recommends 'Test::Class', '== 0.49';
conflicts 'Furl';
CPANFILE
};

subtest 'it creates changeset for change >= into == for pinning' => sub {
    my $app = App::UpdateCPANfile->new('t/fixtures/with_version/cpanfile', 't/fixtures/with_version/cpanfile.snapshot');

    my $pin = $app->create_pin_dependencies_changeset;
    is $pin, [
        [
            "Module::CPANfile",
            "== 1.1003"
        ],
        [
            "Test::Class",
            "== 0.49",
        ],
    ];
};

subtest 'it skips == for pinning' => sub {
    my $app = App::UpdateCPANfile->new('t/fixtures/with_exact/cpanfile', 't/fixtures/with_exact/cpanfile.snapshot');

    my $pin = $app->create_pin_dependencies_changeset;
    is $pin, [];
};

subtest 'it creates changeset which aligns to provided version' => sub {
    my $app = App::UpdateCPANfile->new('t/fixtures/provides_different_version/cpanfile', 't/fixtures/provides_different_version/cpanfile.snapshot');

    my $pin = $app->create_pin_dependencies_changeset;
    is $pin, [
        [
            "Unicode::GCString",
            "== 2013.10"
        ],
    ], 'Unicode::GCString is aligned to 2013.10, not 2018.003';
};

subtest 'it ignores version=undef for pinning' => sub {
    my $app = App::UpdateCPANfile->new('t/fixtures/version_undef/cpanfile', 't/fixtures/version_undef/cpanfile.snapshot');

    my $pin = $app->create_pin_dependencies_changeset;
    is $pin, [
        [
            "TheSchwartz",
            "== 1.15"
        ],
    ];
};

subtest 'it ignores version=undef for updating' => sub {
    my $app = App::UpdateCPANfile->new('t/fixtures/version_undef/cpanfile');

    my $update = $app->create_update_dependencies_changeset;
    is $update, [
    [
        "TheSchwartz",
        "== 1.15"
    ],
]
};

subtest 'it applies limit' => sub {
    my $app = App::UpdateCPANfile->new('t/fixtures/simple/cpanfile', 't/fixtures/simple/cpanfile.snapshot', {limit => 1});

    my $pin = $app->create_pin_dependencies_changeset;
    is $pin, [
        [
            "Module::CPANfile",
            "== 1.1003"
        ],
    ];
};

subtest 'it applies filter' => sub {
    my $app = App::UpdateCPANfile->new('t/fixtures/simple/cpanfile', 't/fixtures/simple/cpanfile.snapshot', {filter => 'Class'});

    my $pin = $app->create_pin_dependencies_changeset;
    is $pin, [
        [
            "Test::Class",
            "== 0.49",
        ],
    ];
};

subtest 'it applies filter' => sub {
    my $app = App::UpdateCPANfile->new('t/fixtures/simple/cpanfile', 't/fixtures/simple/cpanfile.snapshot', {'ignore-filter' => 'Class'});

    my $pin = $app->create_pin_dependencies_changeset;
    is $pin, [
        [
            "Module::CPANfile",
            "== 1.1003"
        ],
    ];
};

subtest 'it handles core modules' => sub {
    # XXX: Core modules are depends on perl's version
    my $app = App::UpdateCPANfile->new('t/fixtures/coremodules/cpanfile', 't/fixtures/coremodules/cpanfile.snapshot');

    subtest 'pin(5.30)' => sub {
        local $] = '5.030000';
        my $pin = $app->create_pin_dependencies_changeset;
        is $pin, [
            [
                "Furl",
                "== 3.13"
            ],
        ], "pin Furl only. Installed File::basename and Encode are core modules.";
    };

    subtest 'update(5.30)' => sub {
        local $] = '5.030000';
        my $update = $app->create_update_dependencies_changeset;
        is $update, [
            [
                "Encode",
                "== 3.06"
            ],
            [
                "Furl",
                "== 3.13"
            ],
        ], 'Encode has latest version in CPAN, but latest File::basename is still a core module.';
    };

    subtest 'update(5.32)' => sub {
    local $] = '5.032000';
        my $update = $app->create_update_dependencies_changeset;
        is $update, [
            [
                "Furl",
                "== 3.13"
            ],
        ], '5.32 has latest Encode';
    };
};

subtest 'it writes to cpanfile' => sub {
    my $dir = t::lib::SetupFixture::prepare_test_code('simple');
    my $app = App::UpdateCPANfile->new("$dir/cpanfile", "$dir/cpanfile.snapshot");

    $app->pin_dependencies;

    my $saved_content = file("$dir/cpanfile")->slurp;
    is $saved_content, <<CPANFILE;
requires 'perl', '5.008001';

requires 'Module::CPANfile', '== 1.1003';

on 'test' => sub {
    requires 'Test::Class', '== 0.49';
};
CPANFILE
};

subtest 'it creates changeset for update' => sub {
    my $dir = t::lib::SetupFixture::prepare_test_code('simple');
    my $app = App::UpdateCPANfile->new("$dir/cpanfile", "$dir/cpanfile.snapshot");

    my $update = $app->create_update_dependencies_changeset;
    is $update, [
        [
            "Module::CPANfile",
            "== 1.1004"
        ],
        [
            "Test::Class",
            "== 0.50",
        ],
    ];
};

subtest 'it handles == for update' => sub {
    my $dir = t::lib::SetupFixture::prepare_test_code('with_exact');

    subtest 'first time' => sub {
        my $app = App::UpdateCPANfile->new("$dir/cpanfile", "$dir/cpanfile.snapshot");

        my $pin = $app->create_update_dependencies_changeset;
        my $update = $app->create_update_dependencies_changeset;
        is $update, [
            [
                "Module::CPANfile",
                "== 1.1004"
            ],
            [
                "Test::Class",
                "== 0.50",
            ],
        ];
        $app->update_dependencies; # write here
    };
    subtest 'second time, there are no change' => sub {
        my $app = App::UpdateCPANfile->new("$dir/cpanfile", "$dir/cpanfile.snapshot");

        my $pin = $app->create_update_dependencies_changeset;
        my $update = $app->create_update_dependencies_changeset;
        is $update, [];
    };
};

subtest 'it writes to cpanfile' => sub {
    my $dir = t::lib::SetupFixture::prepare_test_code('simple');
    my $app = App::UpdateCPANfile->new("$dir/cpanfile", "$dir/cpanfile.snapshot");

    my $update = $app->update_dependencies;
    is $update, [            [
            "Module::CPANfile",
            "== 1.1004"
        ],
        [
            "Test::Class",
            "== 0.50",
        ],
    ], 'It returns changeset';

    my $saved_content = file("$dir/cpanfile")->slurp;
    is $saved_content, <<CPANFILE;
requires 'perl', '5.008001';

requires 'Module::CPANfile', '== 1.1004';

on 'test' => sub {
    requires 'Test::Class', '== 0.50';
};
CPANFILE
};

subtest "it writes suggests, recommends to cpanfile for udpate. It doesn't write conflicts" => sub {
    my $dir = t::lib::SetupFixture::prepare_test_code('suggests');
    my $app = App::UpdateCPANfile->new("$dir/cpanfile", "$dir/cpanfile.snapshot");

    $app->update_dependencies;

    my $saved_content = file("$dir/cpanfile")->slurp;
    is $saved_content, <<CPANFILE;
suggests 'Module::CPANfile', '== 1.1004';
recommends 'Test::Class', '== 0.50';
conflicts 'Furl';
CPANFILE
};

done_testing;

