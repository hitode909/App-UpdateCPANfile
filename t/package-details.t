use strict;
use Test2::V0;

use App::UpdateCPANfile::PackageDetails;
use Test::WWW::Stub;
use Path::Class qw(file);

my $stubbed_res = [ 200, [], [file('t/fixtures/02packages/02packages.details.txt.gz')->slurp] ];
my $guard = Test::WWW::Stub->register(qr<http://.+>, $stubbed_res);

my $details = App::UpdateCPANfile::PackageDetails->new;

subtest 'downloads 02packages' => sub {
    isa_ok $details->details, 'CPAN::PackageDetails';
};

subtest 'it provides package object' => sub {
    is $details->package_object('Furl'), object {
        prop blessed => 'CPAN::PackageDetails::Entry';
        call package_name => 'Furl';
        call path         => 'T/TO/TOKUHIROM/Furl-3.13.tar.gz';
        call version      => '3.13';
    };
    is $details->package_object('___Furl___'), undef;
};

subtest 'it provides latest version for package' => sub {
    is $details->latest_version_for_package('Furl'), '3.13';
    is $details->latest_version_for_package('Unicode::GCString'), '2013.10';
};

done_testing;

