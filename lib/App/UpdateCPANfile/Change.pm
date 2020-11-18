package App::UpdateCPANfile::Change;
use strict;
use warnings;

use CPAN::DistnameInfo;

sub new {
    my ($class, %params) = @_;

    bless { %params }, $class;
}

sub package_name { $_[0]->{package_name} };
sub path { $_[0]->{path} };
sub version { $_[0]->{version} };
sub version_from { $_[0]->{version_from} };

sub dist_name {
    my ($self) = @_;

    CPAN::DistnameInfo->new($self->path)->dist
}

sub prereqs {
    my ($self) = @_;

    [
        [$self->package_name => "== @{[ $self->version ]}"],
        [$self->package_name => "== @{[ $self->version ]}", relationship => 'suggests'],
        [$self->package_name => "== @{[ $self->version ]}", relationship => 'recommends'],
        # Don't touch conflicts
    ];
}

sub as_hashref {
    my ($self) = @_;

    {
        package_name => $self->package_name,
        version      => $self->version,
        version_from => $self->version_from,
        path         => $self->path,
        dist_name    => $self->dist_name,
    }
}

1;