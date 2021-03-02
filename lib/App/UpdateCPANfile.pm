package App::UpdateCPANfile;
use 5.010001;
use strict;
use warnings;
use Module::CPANfile;
use Module::CPANfile::Writer;
use App::UpdateCPANfile::CPANfileSnapshotParser;
use App::UpdateCPANfile::PackageDetails;
use App::UpdateCPANfile::Change;
use Module::CoreList;
use List::Util qw(shuffle);

our $VERSION = "1.0.0";

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
    $self->_save_changes_to_file($changeset);
    return $changeset;
}

sub update_dependencies {
    my ($self) = @_;
    my $changeset = $self->create_update_dependencies_changeset;
    my $writer = $self->writer;
    $self->_save_changes_to_file($changeset);
    return $changeset;
}

sub create_pin_dependencies_changeset {
    my ($self) = @_;

    my $distributions = App::UpdateCPANfile::CPANfileSnapshotParser->scan_deps($self->snapshot_path);

    my $prereqs = $self->parser->prereqs;
    my $added_dependencies = [];

    my $all_phases = {};
    for my $phase ($prereqs->phases) {
        for my $type ($prereqs->types_in($phase)) {
            $all_phases->{$type}++;
        }
    }

    # If arguments are omitted, it defaults to "runtime", "build" and "test" for phases and "requires" and "recommends" for types.
    my $requirements = $prereqs->merged_requirements([$self->parser->prereqs->phases], [keys %$all_phases]);

    for my $module (sort $requirements->required_modules) {
        next if $self->_is_perl($module);
        my $required_version = $requirements->requirements_for_module($module);
        my $installed_module = $self->_find_installed_module($distributions, $module);
        my $installed_version = defined $installed_module && $installed_module->version_for($module);
        next if $self->_is_core_module($module, $installed_version);
        if (defined $installed_module && defined $installed_version && (! defined $required_version || $required_version ne "== $installed_version") && ($installed_version ne 'undef')) {
            push @$added_dependencies, App::UpdateCPANfile::Change->new(package_name => $module, version => $installed_version, path => $installed_module->pathname);
        }

    }

    return $self->_apply_filter($added_dependencies);
}

sub create_update_dependencies_changeset {
    my ($self) = @_;

    my $prereqs = $self->parser->prereqs;

    my $all_phases = {};
    for my $phase ($prereqs->phases) {
        for my $type ($prereqs->types_in($phase)) {
            $all_phases->{$type}++;
        }
    }

    # If arguments are omitted, it defaults to "runtime", "build" and "test" for phases and "requires" and "recommends" for types.
    my $requirements = $prereqs->merged_requirements([$self->parser->prereqs->phases], [keys %$all_phases]);

    my $added_dependencies = [];

    for my $module (sort $requirements->required_modules) {
        my $required_version = $requirements->requirements_for_module($module);
        next if $self->_is_perl($module, $required_version);

        my $package_object = $self->package_details->package_object($module);
        next unless $package_object;
        my $latest_version = $package_object->version;
        next if $self->_is_core_module($module, $latest_version);
        if (defined $latest_version && (! defined $required_version || $required_version ne "== $latest_version") && ($latest_version ne 'undef')) {
            push @$added_dependencies, App::UpdateCPANfile::Change->new(package_name => $module, version => $latest_version, path => $package_object->path);
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

sub _is_perl {
    my ($self, $module, $installed_version) = @_;
    return $module eq 'perl';
}

sub _is_core_module {
    my ($self, $module, $target_version) = @_;
    return unless defined $target_version;

    my $core_version = Module::CoreList::find_version($])->{$module};
    return unless defined $core_version;
    return $core_version eq $target_version;
}

sub _apply_filter {
    my ($self, $changeset) = @_;
    if (my $filter = $self->options->{filter}) {
        $changeset = [ grep { $_->package_name =~ $filter } @$changeset ];
    }
    if (my $ignore_filter = $self->options->{'ignore-filter'}) {
        $changeset = [ grep { $_->package_name !~ $ignore_filter } @$changeset ];
    }

    if ($self->options->{shuffle}) {
        $changeset = [ shuffle(@$changeset) ];
    }

    if (my $limit = $self->options->{limit}) {
        $changeset = [ splice(@$changeset, 0, $limit) ];
    }
    return $changeset;
}

sub _save_changes_to_file {
    my ($self, $changeset) = @_;
    my $writer = $self->writer;

    for my $change (@$changeset) {
        for my $prereq (@{$change->prereqs}) {
            $writer->add_prereq(@$prereq);
        }
    }
    $writer->save($self->path);
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

