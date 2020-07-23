use strict;
use Test2::V0;

use App::UpdateCPANfile::PackageDetails;
use Test::WWW::Stub;
use Path::Class qw(file);

my $stubbed_res = [ 200, [], [file('t/fixtures/02packages/02packages.details.txt.gz')->slurp] ];
my $guard = Test::WWW::Stub->register(qr<http://.+>, $stubbed_res);

subtest 'downloads 02packages' => sub {
    my $details = App::UpdateCPANfile::PackageDetails->new;

    isa_ok $details->details, 'CPAN::PackageDetails';
};

subtest 'it provides latest version for package' => sub {
    my $details = App::UpdateCPANfile::PackageDetails->new;
    is $details->latest_version_for_package('Furl'), '3.13';
    is $details->latest_version_for_package('Unicode::GCString'), '2013.10';
};

done_testing;

