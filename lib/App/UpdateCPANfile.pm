package App::UpdateCPANfile;
use 5.008001;
use strict;
use warnings;
use Module::CPANfile::Writer;

our $VERSION = "0.01";

sub new {
    my ($class, $path) = @_;
    bless {
        path => $path,
    }, $class;
}

sub path {
    $_[0]->{path} // 'cpanfile';
}

sub writer {
    my ($self) = @_;

    $self->{writer} //= Module::CPANfile::Writer->new($self->path);
}


1;
__END__

=encoding utf-8

=head1 NAME

App::UpdateCPANfile - cpanfile updater

=head1 SYNOPSIS

    use App::UpdateCPANfile;

=head1 DESCRIPTION

App::UpdateCPANfile reads cpanfile, pin dependencies, update dependencies and write back to cpanfile.

=head1 LICENSE

Copyright (C) hitode909.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

hitode909 E<lt>hitode909@gmail.comE<gt>

=cut

