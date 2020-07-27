package App::UpdateCPANfile::CPANfileSnapshotParser;
use strict;
use warnings;
use Carton::Snapshot;

sub scan_deps {
    my ($class, $path) = @_;

    my $snapshot = Carton::Snapshot->new(path => $path);
    $snapshot->load;
    [ $snapshot->distributions ];
}

1;