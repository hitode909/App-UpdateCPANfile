requires 'perl', '5.008001';

requires 'Module::CPANfile';
requires 'Module::CPANfile::Writer';
requires 'CPAN::PackageDetails';
requires 'CPAN::DistnameInfo';
requires 'Furl';
requires 'IO::Socket::SSL';
requires 'IO::String';

on 'test' => sub {
    requires 'Test2::V0';
    requires 'Cwd';
    requires 'FindBin';
    requires 'File::Spec::Functions';
    requires 'File::Temp';
    requires 'File::Copy::Recursive';
    requires 'Path::Class';
    requires 'Test::WWW::Stub';
};

