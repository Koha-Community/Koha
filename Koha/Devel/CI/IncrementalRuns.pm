package Koha::Devel::CI::IncrementalRuns;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use File::Path  qw(make_path);
use File::Slurp qw(read_file write_file);
use File::Basename;
use JSON            qw(from_json to_json);
use List::MoreUtils qw(firstval uniq);

use Koha::Devel::Files;

=head1 NAME

Koha::Devel::CI::IncrementalRuns - A module for managing incremental CI runs in Koha development.

=head1 SYNOPSIS

    use Koha::Devel::CI::IncrementalRuns;

    my $ci = Koha::Devel::CI::IncrementalRuns->new({
        context      => 'tidy',
    });

    my @files_to_test = $ci->get_files_to_test('pl');
    $ci->report_results($results);

=head1 DESCRIPTION

Koha::Devel::CI::IncrementalRuns is a module designed to manage incremental CI runs in the Koha development environment. It provides functionality to determine which files need to be tested based on previous CI runs and to report the results of those tests.

=head1 METHODS

=head2 new

    my $ci = Koha::Devel::CI::IncrementalRuns->new({
        incremental_run => 1,
        git_repo_dir    => '/path/to/repo',
        repo_url        => 'https://gitlab.com/koha-community/koha-ci-results.git',
        report          => 1,
        token           => 'your_token',
        test_name       => 'test_name',
        context         => 'tidy',
    });

Creates a new instance of Koha::Devel::CI::IncrementalRuns. The constructor accepts a hash reference with the following keys:
- `incremental_run`: A flag indicating whether to run incrementally the tests [default env KOHA_CI_INCREMENTAL_RUNS]
- `git_repo_dir`: The directory where the Git repository is stored [default /tmp/koha-ci-results]
- `repo_url`: The URL of the Git repository [default env KOHA_CI_INCREMENTAL_RUN_REPO_URL]
- `report`: A flag indicating whether to report the results [default env KOHA_CI_INCREMENTAL_RUNS_REPORT]
- `token`: The token for authenticating with the Git repository [default env KOHA_CI_INCREMENTAL_RUNS_TOKEN]
- `test_name`: The name of the test [default name of the test]
- `context`: The context for file exclusions

=cut

sub new {
    my ( $class, $args ) = @_;

    my $self = {
        incremental_run => $ENV{KOHA_CI_INCREMENTAL_RUNS} // 0,
        git_repo_dir    => $args->{git_repo_dir}          // q{/tmp/koha-ci-results},
        repo_url        => $args->{repo_url}              // $ENV{KOHA_CI_INCREMENTAL_RUN_REPO_URL}
            // q{https://gitlab.com/koha-community/koha-ci-results.git},
        report    => $args->{report} // $ENV{KOHA_CI_INCREMENTAL_RUNS_REPORT},
        token     => $args->{token}  // $ENV{KOHA_CI_INCREMENTAL_RUNS_TOKEN},
        test_name => $args->{test_name},
        context   => $args->{context},
    };

    if ( $self->{incremental_run} ) {

        my $codename = qx{lsb_release -s -c 2> /dev/null};
        die "Cannot use increment runs if codename is not set (lsb_release not available?)" unless $codename;

        chomp $codename;

        unless ( $self->{test_name} ) {
            my @caller_info     = caller();
            my $script_filename = $caller_info[1];
            $self->{test_name} = basename($script_filename);
            $self->{test_name} =~ s|/|_|g;
            $self->{test_name} =~ s|\..*$||g;
        }

        $self->{test_dir} = sprintf "%s/%s", $self->{test_name}, $codename;

        if ( $self->{git_repo_dir} && $self->{repo_url} ) {
            unless ( -d $self->{git_repo_dir} ) {
                qx{git clone $self->{repo_url} $self->{git_repo_dir}};
            }
            qx{git -C $self->{git_repo_dir} fetch origin};

            make_path("$self->{git_repo_dir}/$self->{test_dir}");
        }
    }

    bless $self, $class;
    return $self;
}

=head2 get_files_to_test

    my @files_to_test = $ci->get_files_to_test('pl');

Determines the list of files to be tested based on the incremental run settings. If incremental runs are enabled, it retrieves the list of files that have been modified since the last build. Otherwise, it retrieves all relevant files.

=cut

sub get_files_to_test {
    my ( $self, $filetype ) = @_;

    my @files;
    my $dev_files = Koha::Devel::Files->new( { context => $self->{context} } );
    my $no_history;
    if ( $self->{incremental_run} ) {
        my @koha_commit_history   = qx{git log --abbrev=10 --pretty=format:"%h"};
        my @tested_commit_history = qx{ls $self->{git_repo_dir}/$self->{test_dir}};
        chomp for @koha_commit_history, @tested_commit_history;
        if (@tested_commit_history) {
            my $last_build_commit = firstval {
                my $commit = $_;
                grep { $_ eq $commit } @tested_commit_history
            }
            @koha_commit_history;
            if ($last_build_commit) {
                @files = @{ from_json( read_file("$self->{git_repo_dir}/$self->{test_dir}/$last_build_commit") ) };
                @files = $dev_files->remove_exceptions( \@files, $filetype );
                push @files, $dev_files->ls_files( $filetype, "$last_build_commit HEAD" );
            } else {

                # In case we run on a branch that does not have ancestor commits in the history
                # We should not reach this on Jenkins
                $no_history = 1;
            }
        } else {
            $no_history = 1;
        }
    }
    @files = $dev_files->ls_files($filetype) if !$self->{incremental_run} || $no_history;

    return uniq @files;
}

=head2 report_results

    $ci->report_results($results);

Reports the results of the tests by committing the list of failures to the Git repository. This method is called only if the `report` flag is set.

=cut

sub report_results {
    my ( $self, $results ) = @_;

    return unless $self->{report};

    my $commit_id = qx{git rev-parse --short=10 HEAD};
    chomp $commit_id;

    my $failure_file = "$self->{git_repo_dir}/$self->{test_dir}/$commit_id";
    my $failures     = [
        sort map {
            my ( $file, $exit_code ) = ( $_, $results->{$_} );
            ( $exit_code ? $file : () )
        } keys %$results
    ];

    write_file( $failure_file, to_json($failures) );

    qx{git -C $self->{git_repo_dir} add $failure_file};
    qx{git -C $self->{git_repo_dir} commit -m "$commit_id - $self->{test_dir}"};
    ( my $push_domain = $self->{repo_url} ) =~ s{^https://}{};
    my $push_url = "https://gitlab-ci-token:$self->{token}\@$push_domain";
    qx{git -C $self->{git_repo_dir} push $push_url main};
}

1;
