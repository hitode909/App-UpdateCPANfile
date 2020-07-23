package App::UpdateCPANfile::CPANfileSnapshotParser;
use strict;
use warnings;

sub scan_deps {
  my ($class, $path) = @_;

  open my $fh, '<', $path or die $!;

  my @deps;
  while ( defined( my $line = <$fh> ) ) {
     if ( $line =~ m/pathname: ([^\s]+)/ ) {
       push @deps, $1;
     }
  }

  \@deps;
}

1;