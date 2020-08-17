requires 'perl', '5.008001';

requires 'Module::CPANfile';
requires 'Module::CPANfile::Writer';
requires 'CPAN::PackageDetails';
requires 'CPAN::DistnameInfo';
requires 'LWP::UserAgent';
requires 'IO::String';
requires 'Getopt::Long';
requires 'Carton';
requires 'CPAN::Meta::Prereqs', '>= 2.150010';
requires 'JSON';

on 'test' => sub {
    requires 'Test2::V0';
    requires 'Cwd';
    requires 'FindBin';
    requires 'File::Spec::Functions';
    requires 'File::Temp';
    requires 'File::Copy::Recursive';
    requires 'Path::Class';
    requires 'Test::WWW::Stub';
    requires 'Module::CoreList', '>= 5.20200717';
};