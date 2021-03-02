# NAME

update-cpanfile - cpanfile updater

# SYNOPSIS

update-cpanfile has two sub commands.

    $ update-cpanfile pin
    $ update-cpanfile update

# PIN

Pin command aligns the package versions in cpanfile to versions in cpanfile.snapshot.
This operation has no side effects for your project's execution environment, so it is useful to pin the versions before update packages.

    $ update-cpanfile pin $PATH_TO_CPANFILE $PATH_TO_CPANFILE_SNAPSHOT

# UPDATE

    $ update-cpanfile update $PATH_TO_CPANFILE

Update command updates the package versions in cpanfile to latest versions in 02packages.txt.
With this command, you can make your dependant libraries latest.
You may run this command from CI, and create Pull Request when there are some diffs.

Update policy is below.

- The item is listed in cpanfile.
- The item is not a core module.
- The item is not a perl.

# TARGET PROJECT

By default, update-cpanfile updates cpanfile in current directory.
To execute for other project in directory, you can specify path of cpanfile and cpanfile.snapshot.

    $ update-cpanfile pin <path_to_cpanfile> <path_to_cpanfile.snapshot>
    $ update-cpanfile update <path_to_cpanfile>

# OPTIONS

- --limit=n
- --filter=FILTER
- --ignore-filter=FILTER
- --shuffle
- --output={text|json}
- --version

Default output format is `text`.
When you set `--output json`, the output format is like this: \[{package\_name: PACKAGE\_NAME, version: VERSION, path: PATH, dist\_name: DIST\_NAME}, ...\]

    [{"package_name":"File::Copy::Recursive","version":"0.45","path":"D/DM/DMUEY/File-Copy-Recursive-0.45.tar.gz","dist_name":"File-Copy-Recursive"}]

`shuffle` option works fine with `--limit=1`. `--limit=1 --shuffle` will update a random picked package.
