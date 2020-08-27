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
    ];
}

1;