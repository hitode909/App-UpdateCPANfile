package t::lib::SetupFixture;
use Cwd ();
use FindBin;
use File::Spec::Functions qw/catfile/;
use File::Temp qw(tempdir);
use File::Copy::Recursive;

sub prepare_test_code {
    my ($name) = @_;

    my $base_directory = catfile($FindBin::Bin, 'fixtures', $name);
    my $tmpdir = Cwd::abs_path(tempdir);

    unless (-d $base_directory) {
        die "$name is not defined";
    }

    File::Copy::Recursive::dircopy($base_directory, $tmpdir);
    $tmpdir;
}

1;