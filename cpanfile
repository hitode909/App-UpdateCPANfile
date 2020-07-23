requires 'perl', '5.008001';

requires 'Module::CPANfile';
requires 'Module::CPANfile::Writer';
requires 'CPAN::PackageDetails';
requires 'CPAN::DistnameInfo';

on 'test' => sub {
    requires 'Test2::V0';
};

