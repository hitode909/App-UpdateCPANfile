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
            "1.1003"
        ],
        [
            "Test::Class",
            "0.49",
        ],
    ];
};

subtest 'it writes to cpanfile' => sub {
    my $dir = t::lib::SetupFixture::prepare_test_code('simple');
    my $app = App::UpdateCPANfile->new("$dir/cpanfile", "$dir/cpanfile.snapshot");

    $app->pin_dependencies;

    my $saved_content = file("$dir/cpanfile")->slurp;
    is $saved_content, <<CPANFILE;
requires 'perl', '5.008001';

requires 'Module::CPANfile', '1.1003';

on 'test' => sub {
    requires 'Test::Class', '0.49';
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
            "1.1004"
        ],
        [
            "Test::Class",
            "0.50",
        ],
    ];
};

subtest 'it writes to cpanfile' => sub {
    my $dir = t::lib::SetupFixture::prepare_test_code('simple');
    my $app = App::UpdateCPANfile->new("$dir/cpanfile", "$dir/cpanfile.snapshot");

    $app->update_dependencies;

    my $saved_content = file("$dir/cpanfile")->slurp;
    is $saved_content, <<CPANFILE;
requires 'perl', '5.008001';

requires 'Module::CPANfile', '1.1004';

on 'test' => sub {
    requires 'Test::Class', '0.50';
};
CPANFILE
};


done_testing;

