use strict;
use Test2::V0;

use App::UpdateCPANfile::PackageDetails;

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

