use strict;
use Test::More 0.98;

use App::UpdateCPANfile;

subtest 'initialize' => sub {
    my $app = App::UpdateCPANfile->new('cpanfile');
    isa_ok $app, 'App::UpdateCPANfile';
    is $app->path, 'cpanfile';
};

subtest 'initialize without path' => sub {
    my $app = App::UpdateCPANfile->new;
    is $app->path, 'cpanfile';
};

subtest 'it parses cpanfile' => sub {
    my $app = App::UpdateCPANfile->new;
    isa_ok $app->parser, 'Module::CPANfile';
    isa_ok $app->writer, 'Module::CPANfile::Writer';
};

done_testing;

