requires 'perl', '5.008001';

requires 'Module::CPANfile', '== 1.1004';
requires 'Module::CPANfile::Writer', '== 0.01';
requires 'CPAN::PackageDetails', '== 0.261';
requires 'CPAN::DistnameInfo', '== 0.12';
requires 'LWP::UserAgent', '== 6.46';
requires 'IO::String', '== 1.08';
requires 'Getopt::Long';
requires 'Carton', '== 1.000034';
requires 'CPAN::Meta::Prereqs', '>= 2.150010';

on 'test' => sub {
    requires 'Test2::V0', '== 0.000132';
    requires 'Cwd', '== 3.75';
    requires 'FindBin';
    requires 'File::Spec::Functions', '== 3.75';
    requires 'File::Temp';
    requires 'File::Copy::Recursive', '== 0.45';
    requires 'Path::Class', '== 0.37';
    requires 'Test::WWW::Stub', '== 0.10';
    requires 'Module::CoreList', '== 5.20200717';
};