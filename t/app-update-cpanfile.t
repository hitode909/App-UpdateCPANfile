use strict;
use Test2::V0;

use App::UpdateCPANfile;

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

subtest 'it creates changeset for pin dependencies' => sub {
    my $app = App::UpdateCPANfile->new('t/fixtures/simple/cpanfile', 't/fixtures/simple/cpanfile.snapshot');

    my $pin = $app->create_pin_dependencies_changeset;
    is $pin, [
        [
            "Module::CPANfile",
            "1.1004"
        ],
        [
            "Test::Class",
            "0.50",
            "relationship",
            "test"
        ],
    ];
};



done_testing;

