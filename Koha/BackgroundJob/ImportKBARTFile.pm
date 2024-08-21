package Koha::BackgroundJob::ImportKBARTFile;

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Try::Tiny qw( catch try );

use C4::Context;

use Koha::ERM::EHoldings::Titles;
use Koha::SearchEngine::Indexer;

use base 'Koha::BackgroundJob';

=head1 NAME

ImportKBARTFile - Create new eHoldings titles from a KBART file

This is a subclass of Koha::BackgroundJob.

=head1 API

=head2 Class methods

=head3 job_type

Define the job type of this job.

=cut

sub job_type {
    return 'import_from_kbart_file';
}

=head3 process

Process the import.

=cut

sub process {
    my ( $self, $args ) = @_;

    if ( $self->status eq 'cancelled' ) {
        return;
    }

    $self->start;
    my @messages;
    my $titles_imported  = 0;
    my $duplicate_titles = 0;
    my $failed_imports   = 0;
    my $total_rows;
    my $file_name = $args->{file_name};
    my $report    = {
        duplicates_found => undef,
        titles_imported  => undef,
        file_name        => $file_name,
        total_rows       => undef,
        failed_imports   => undef
    };

    try {
        my $column_headers       = $args->{column_headers};
        my $invalid_columns      = $args->{invalid_columns};
        my $rows                 = $args->{rows};
        my $package_id           = $args->{package_id};
        my $create_linked_biblio = $args->{create_linked_biblio};

        if ( scalar( @{$rows} ) == 0 ) {
            push @messages, {
                code => 'no_rows',
                type => 'error',
            };
            $self->status('failed')->store;
        }

        $self->size( scalar( @{$rows} ) )->store;
        $total_rows = scalar( @{$rows} );

        my @biblio_ids;

        foreach my $row ( @{$rows} ) {
            next if !$row;
            my $new_title   = _create_title_hash_from_line_data( $row, $column_headers, $invalid_columns );
            my $title_match = _check_for_matching_title( $new_title, $package_id );

            if ($title_match) {
                $duplicate_titles++;
                push @messages, {
                    code          => 'title_already_exists',
                    type          => 'warning',
                    error_message => undef,
                    title         => $new_title->{publication_title}
                };
            } else {
                try {
                    my $formatted_title = _format_title($new_title);
                    if ( !$formatted_title->{publication_title} ) {
                        push @messages, {
                            code     => 'no_title_found',
                            type     => 'error',
                            title    => '(Unknown)',
                            title_id => $formatted_title->{external_id}
                        };
                        $failed_imports++;
                    } else {
                        my $imported_title = Koha::ERM::EHoldings::Title->new($formatted_title)
                            ->store( { create_linked_biblio => $create_linked_biblio } );
                        push( @biblio_ids, $imported_title->biblio_id ) if $create_linked_biblio;
                        _create_linked_resource(
                            {
                                title      => $imported_title,
                                package_id => $package_id
                            }
                        );

                        # No need to add a message for a successful import,
                        # files could have 1000s of titles which will lead to lots of messages in background_job->data
                        $titles_imported++ if $imported_title;
                    }
                } catch {
                    $failed_imports++;
                    push @messages, {
                        code          => 'title_failed',
                        type          => 'error',
                        error_message => $_->{msg} || "Please check your file",
                        title         => $new_title->{publication_title}
                    }
                };
            }
            $self->step;
        }

        if ( scalar(@biblio_ids) > 0 ) {
            my $indexer = Koha::SearchEngine::Indexer->new( { index => $Koha::SearchEngine::BIBLIOS_INDEX } );
            $indexer->index_records( \@biblio_ids, "specialUpdate", "biblioserver" );
        }

        $report->{duplicates_found} = $duplicate_titles;
        $report->{titles_imported}  = $titles_imported;
        $report->{total_rows}       = $total_rows;
        $report->{failed_imports}   = $failed_imports;
        $report->{package_id}       = $package_id;

        my $data = $self->decoded_data;
        $data->{messages} = \@messages;
        $data->{report}   = $report;

        # Remove the file content as this is no longer needed and can be very large
        $data->{file}->{file_content} = undef;

        $self->finish($data);
    } catch {
        warn $_;
    }
}

=head3 enqueue

Enqueue the new job

=cut

sub enqueue {
    my ( $self, $args ) = @_;

    return unless exists $args->{column_headers};

    $self->SUPER::enqueue(
        {
            job_size  => 1,
            job_args  => $args,
            job_queue => 'long_tasks',
        }
    );
}

=head3 _format_title

Formats a title to fit the names of the database fields in Koha

Kbart field "title_id" = "external_id" in Koha
Kbart field "coverage_notes" = "notes" in Koha

=cut

sub _format_title {
    my ($title) = @_;

    $title->{external_id} = $title->{title_id};
    delete $title->{title_id};

    # Some files appear to use coverage_notes instead of "notes" as in the KBART standard
    if ( exists $title->{coverage_notes} ) {
        $title->{notes} = $title->{coverage_notes};
        delete $title->{coverage_notes};
    }

    return $title;
}

=head3 _create_title_hash_from_line_data

Takes a line and creates a hash of the values mapped to the column headings
Only accepts fields that are in the list of permitted KBART fields, other fields are ignored
(This is identified to the user on the background job status page)

=cut

sub _create_title_hash_from_line_data {
    my ( $row, $column_headers, $invalid_columns ) = @_;

    my %new_title;

    @new_title{ @{$column_headers} } = @$row;

    # If the file has been converted from CSV to TSV for import, then some titles containing commas will be enclosed in ""
    my $first_char = substr( $new_title{publication_title}, 0, 1 );
    my $last_char  = substr( $new_title{publication_title}, -1 );
    if ( $first_char eq '"' && $last_char eq '"' ) {
        $new_title{publication_title} =~ s/^"|"$//g;
    }

    # Remove any additional columns
    foreach my $invalid_column (@$invalid_columns) {
        delete $new_title{$invalid_column};
    }

    return \%new_title;
}

=head3 _check_for_matching_title

Checks whether this title already exists to avoid duplicates

=cut

sub _check_for_matching_title {
    my ( $title, $package_id ) = @_;

    my $match_parameters = {};
    $match_parameters->{print_identifier}  = $title->{print_identifier}  if $title->{print_identifier};
    $match_parameters->{online_identifier} = $title->{online_identifier} if $title->{online_identifier};

    # Use external_id in case title exists for a different provider, we want to add it for the new provider
    $match_parameters->{external_id} = $title->{title_id} if $title->{title_id};

    # We should also check the date_first_issue_online for serial publications
    $match_parameters->{date_first_issue_online} = $title->{date_first_issue_online}
        if $title->{date_first_issue_online};

    # If no match parameters are provided in the file we should add the new title
    return 0 if !%$match_parameters;

    my $matching_title_found;
    my @title_matches = Koha::ERM::EHoldings::Titles->search($match_parameters)->as_list;
    foreach my $title_match (@title_matches) {
        my $resource = Koha::ERM::EHoldings::Resources->find( { title_id => $title_match->title_id } );
        $matching_title_found = 1 if $resource->package_id == $package_id;
    }

    return $matching_title_found;
}

=head3 _create_linked_resource

Creates a resource for a newly stored title.

=cut

sub _create_linked_resource {
    my ($args) = @_;

    my $title      = $args->{title};
    my $package_id = $args->{package_id};

    my $title_id = $title->title_id;
    my ( $date_first_issue_online, $date_last_issue_online ) = _get_first_and_last_issue_dates($title);
    my $resource = Koha::ERM::EHoldings::Resource->new(
        {
            title_id   => $title_id,
            package_id => $package_id,
            started_on => $date_first_issue_online,
            ended_on   => $date_last_issue_online,
        }
    )->store;

    return;
}

=head3 _get_first_and_last_issue_dates

Gets and formats a date for storing on the resource. Dates can come from files in YYYY, YYYY-MM or YYYY-MM-DD format

=cut

sub _get_first_and_last_issue_dates {
    my ($title) = @_;

    return ( undef, undef ) if ( !$title->date_first_issue_online && !$title->date_last_issue_online );

    my $date_first_issue_online =
          $title->date_first_issue_online =~ /^\d{4}((-\d{2}-\d{2}$|-\d{2}$)|$)$/
        ? $title->date_first_issue_online
        : undef;
    my $date_last_issue_online =
        $title->date_last_issue_online =~ /^\d{4}((-\d{2}-\d{2}$|-\d{2}$)|$)$/ ? $title->date_last_issue_online : undef;

    $date_first_issue_online = $date_first_issue_online . '-01-01'
        if $date_first_issue_online && $date_first_issue_online =~ /^\d{4}$/;
    $date_last_issue_online = $date_last_issue_online . '-01-01'
        if $date_last_issue_online && $date_last_issue_online =~ /^\d{4}$/;
    $date_first_issue_online = $date_first_issue_online . '-01'
        if $date_first_issue_online && $date_first_issue_online =~ /^\d{4}-\d{2}$/;
    $date_last_issue_online = $date_last_issue_online . '-01'
        if $date_last_issue_online && $date_last_issue_online =~ /^\d{4}-\d{2}$/;

    return ( $date_first_issue_online, $date_last_issue_online );
}

1;
