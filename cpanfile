requires 'perl', '5.008001';

requires 'Module::CPANfile', '1.1004';
requires 'Module::CPANfile::Writer', '0.01';
requires 'CPAN::PackageDetails', '0.261';
requires 'CPAN::DistnameInfo', '0.12';
requires 'LWP::UserAgent', '6.46';
requires 'IO::String', '1.08';

on 'test' => sub {
    requires 'Test2::V0', '0.000130';
    requires 'Cwd';
    requires 'FindBin';
    requires 'File::Spec::Functions';
    requires 'File::Temp';
    requires 'File::Copy::Recursive', '0.45';
    requires 'Path::Class', '0.37';
    requires 'Test::WWW::Stub', '0.10';
};

