package App::UpdateCPANfile;
use 5.008001;
use strict;
use warnings;
use Module::CPANfile;
use Module::CPANfile::Writer;
use App::UpdateCPANfile::CPANfileSnapshotParser;
use App::UpdateCPANfile::PackageDetails;
use CPAN::DistnameInfo;
use Module::CoreList;

our $VERSION = "0.03";

sub new {
    my ($class, $path, $snapshot_path, $options) = @_;
    bless {
        path => $path,
        snapshot_path => $snapshot_path,
        options => $options,
    }, $class;
}

sub path {
    $_[0]->{path} // 'cpanfile';
}

sub snapshot_path {
    $_[0]->{snapshot_path} // 'cpanfile.snapshot';
}

sub options {
    $_[0]->{options} // {};
}

sub parser {
    my ($self) = @_;

    $self->{parser} //= Module::CPANfile->load($self->path);
}

sub writer {
    my ($self) = @_;

    $self->{writer} //= Module::CPANfile::Writer->new($self->path);
}

sub package_details {
    my ($self) = @_;

    $self->{package_details} //= App::UpdateCPANfile::PackageDetails->new;
}

sub pin_dependencies {
    my ($self) = @_;
    my $changeset = $self->create_pin_dependencies_changeset;
    my $writer = $self->writer;
    for my $change (@$changeset) {
        $writer->add_prereq(@$change);
    }
    $writer->save($self->path);
}

sub update_dependencies {
    my ($self) = @_;
    my $changeset = $self->create_update_dependencies_changeset;
    my $writer = $self->writer;
    for my $change (@$changeset) {
        $writer->add_prereq(@$change);
    }
    $writer->save($self->path);
}

sub create_pin_dependencies_changeset {
    my ($self) = @_;

    my $distributions = App::UpdateCPANfile::CPANfileSnapshotParser->scan_deps($self->snapshot_path);

    my $added_dependencies = [];

    my $prereqs = $self->parser->prereqs->as_string_hash;
    for my $module (sort $self->parser->prereqs->merged_requirements->required_modules) {
        next if $self->_should_skip($module);
        my $required_version = $self->parser->prereqs->merged_requirements->requirements_for_module($module);
        my $installed_module = $self->_find_installed_module($distributions, $module);
        my $installed_version = defined $installed_module && $installed_module->version_for($module);
        if (defined $installed_module && defined $installed_version && (! defined $required_version || $required_version ne "== $installed_version") && ($installed_version ne 'undef')) {
            push @$added_dependencies, [ $module, "== $installed_version"];
        }

    }

    return $self->_apply_filter($added_dependencies);
}

sub create_update_dependencies_changeset {
    my ($self) = @_;

    my $prereqs = $self->parser->prereqs->as_string_hash;

    my $added_dependencies = [];

    for my $phase (sort keys %$prereqs) {
        for my $module (sort keys %{$prereqs->{$phase}->{requires}}) {
            next if $self->_should_skip($module);
            my $version = $prereqs->{$phase}->{$module};

            my $latest_version = $self->package_details->latest_version_for_package($module);
            if (defined $latest_version && (! defined $version || $version ne $latest_version)) {
                push @$added_dependencies, [ $module, "== $latest_version"];
            }
        }
    }
    return $self->_apply_filter($added_dependencies);
}

sub _find_installed_module {
    my ($self, $distributions, $module) = @_;;
    for my $dist (@$distributions) {
        return $dist if $dist->provides_module($module);
    }
    return undef;
}

sub _should_skip {
    my ($self, $module) = @_;
    return 1 if $module eq 'perl';
    return Module::CoreList::is_core($module);
}

sub _apply_filter {
    my ($self, $changeset) = @_;
    if (my $filter = $self->options->{filter}) {
        $changeset = [ grep { $_->[0] =~ $filter } @$changeset ];
    }
    if (my $ignore_filter = $self->options->{'ignore-filter'}) {
        $changeset = [ grep { $_->[0] !~ $ignore_filter } @$changeset ];
    }

    if (my $limit = $self->options->{limit}) {
        $changeset = [ splice(@$changeset, 0, $limit) ];
    }
    return $changeset;
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

=head1 SEE ALSO

L<update-cpanfile> for command-line usage.

=head1 LICENSE

Copyright (C) hitode909.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

hitode909 E<lt>hitode909@gmail.comE<gt>

=cut

