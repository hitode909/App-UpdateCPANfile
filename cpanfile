requires 'perl', '5.008001';

requires 'Module::CPANfile';
requires 'Module::CPANfile::Writer';
requires 'CPAN::PackageDetails';

on 'test' => sub {
    requires 'Test2::V0';
};

