package App::UpdateCPANfile::PackageDetails;
use strict;
use warnings;

use CPAN::PackageDetails;
use Furl;
use IO::String;

sub new {
    my ($class) = @_;

    bless {}, $class;
}

sub details {
    my ($self) = @_;
    if ($self->{details}) {
        return $self->{details};
    }

    my $furl = Furl->new(
        agent   => 'UpdateCPANfile/0.1',
        timeout => 60,
    );

    my $file = IO::String->new;
    my $res = $furl->get('http://www.cpan.org/modules/02packages.details.txt.gz');
    $file->print($res->content);
    $file->setpos(0);

    $self->{details} = CPAN::PackageDetails->read( $file );
}

sub latest_version_for_package {
    my ($self, $package) = @_;
    my ($package_object) = $self->details->entries->get_entries_by_package($package);
    return undef unless $package_object;
    return $package_object->version;
}

1;