package App::UpdateCPANfile::PackageDetails;
use strict;
use warnings;

use CPAN::PackageDetails;
use LWP::UserAgent;
use IO::String;

sub new {
    my ($class) = @_;

    bless {}, $class;
}

# Parsing detail is heavy operation.
my $details_cache;

sub details {
    my ($self) = @_;
    if ($details_cache) {
        return $details_cache;
    }

    my $agent = LWP::UserAgent->new(
        agent   => 'UpdateCPANfile/0.1',
        timeout => 60,
    );

    my $file = IO::String->new;
    my $res = $agent->get('http://www.cpan.org/modules/02packages.details.txt.gz');
    $file->print($res->content);
    $file->setpos(0);

    $details_cache = CPAN::PackageDetails->read( $file );
}

sub clear_details_cache {
    $details_cache = undef;
}

sub package_object {
    my ($self, $package) = @_;
    my ($package_object) = $self->details->entries->get_entries_by_package($package);
    $package_object;
}

sub latest_version_for_package {
    my ($self, $package) = @_;
    my $package_object = $self->package_object($package);
    return undef unless $package_object;
    return $package_object->version;
}

1;