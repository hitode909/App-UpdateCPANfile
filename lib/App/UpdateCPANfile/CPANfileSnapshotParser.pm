package App::UpdateCPANfile::CPANfileSnapshotParser;
use strict;
use warnings;

use CPAN::DistnameInfo;

sub scan_deps {
  my ($class, $path) = @_;

  open my $fh, '<', $path or die $!;

  my @deps;
  while ( defined( my $line = <$fh> ) ) {
     if ( $line =~ m/pathname: ([^\s]+)/ ) {
       push @deps, CPAN::DistnameInfo->new($1);
     }
  }

  \@deps;
}

1;