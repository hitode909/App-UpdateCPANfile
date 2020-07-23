use strict;
use Test::More 0.98;

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

done_testing;

