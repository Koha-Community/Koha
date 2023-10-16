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
use JSON qw( decode_json encode_json );
use Try::Tiny qw( catch try );
use MIME::Base64 qw( decode_base64 );
use POSIX qw( floor );

use C4::Context;

use Koha::ERM::EHoldings::Titles;

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
    my $total_lines;
    my $file_name = $args->{file}->{filename};
    my $report    = {
        duplicates_found => undef,
        titles_imported  => undef,
        file_name        => $file_name,
        total_lines      => undef,
        failed_imports   => undef
    };

    try {
        my $file = $args->{file};
        my $package_id = $args->{package_id};
        my ( $column_headers, $lines ) = format_file($file);

        if ( scalar( @{$lines} ) == 0 ) {
            push @messages, {
                code          => 'job_failed',
                type          => 'error',
                error_message => 'No valid lines were found in this file. Please check the file formatting.',
            };
            $self->status('failed')->store;
        }

        $self->size( scalar( @{$lines} ) )->store;
        $total_lines = scalar( @{$lines} );

        foreach my $line ( @{$lines} ) {
            next if !$line;
            my $new_title   = create_title_hash_from_line_data( $line, $column_headers );
            my $title_match = Koha::ERM::EHoldings::Titles->search( { external_id => $new_title->{title_id} } )->count;

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
                    my $formatted_title = format_title($new_title);
                    if ( !$formatted_title->{publication_title} ) {
                        push @messages, {
                            code          => 'title_failed',
                            type          => 'error',
                            error_message => "No publication_title found for title_id: ",
                            title         => '(Unknown)',
                            title_id      => $formatted_title->{external_id}
                        };
                        $failed_imports++;
                    } else {
                        my $imported_title = Koha::ERM::EHoldings::Title->new($formatted_title)->store;
                        my $title_id = $imported_title->title_id;
                        Koha::ERM::EHoldings::Resource->new( { title_id => $title_id, package_id => $package_id } )
                            ->store;

                        # No need to add a message for a successful import,
                        # files could have 1000s of titles which will lead to lots of messages in background_job->data
                        $titles_imported++ if $imported_title;
                    }
                } catch {
                    $failed_imports++;
                    push @messages, {
                        code          => 'title_failed',
                        type          => 'error',
                        error_message => $_->{msg},
                        title         => $new_title->{publication_title}
                    }
                };
            }
            $self->step;
        }

        $report->{duplicates_found} = $duplicate_titles;
        $report->{titles_imported}  = $titles_imported;
        $report->{total_lines}      = $total_lines;
        $report->{failed_imports}   = $failed_imports;

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

    return unless exists $args->{file};

    $self->SUPER::enqueue(
        {
            job_size  => 1,
            job_args  => $args,
            job_queue => 'long_tasks',
        }
    );
}

=head3 format_title

Formats a title to fit the names of the database fields in Koha

Kbart field "title_id" = "external_id" in Koha
Kbart field "coverage_notes" = "notes" in Koha

=cut

sub format_title {
    my ($title) = @_;

    $title->{external_id} = $title->{title_id};
    delete $title->{title_id};

    # Some files appear to use coverage_notes instead of "notes" as in the KBART standard
    if ( $title->{coverage_notes} ) {
        $title->{notes} = $title->{coverage_notes};
        delete $title->{coverage_notes};
    }

    return $title;
}

=head3 format_file

Formats a file to provide report headers and lines to be processed

=cut

sub format_file {
    my ($file) = @_;

    my $file_content = decode_base64( $file->{file_content} );
    $file_content =~ s/\n/\r/g;
    my @lines          = split /\r/, $file_content;
    my @column_headers = split /\t/, $lines[0];
    shift @lines;    # Remove headers row
    my @remove_null_lines = grep $_ ne '', @lines;

    return ( \@column_headers, \@remove_null_lines );
}

=head3 create_title_hash_from_line_data

Takes a line and creates a hash of the values mapped to the column headings

=cut

sub create_title_hash_from_line_data {
    my ( $line, $column_headers ) = @_;

    my %new_title;
    my @values = split /\t/, $line;

    @new_title{ @{$column_headers} } = @values;

    return \%new_title;
}

=head3 get_valid_headers

Returns a list of permitted headers in a KBART phase II file

=cut

sub get_valid_headers {
    return (
        'publication_title',
        'print_identifier',
        'online_identifier',
        'date_first_issue_online',
        'num_first_vol_online',
        'num_first_issue_online',
        'date_last_issue_online',
        'num_last_vol_online',
        'num_last_issue_online',
        'title_url',
        'first_author',
        'title_id',
        'embargo_info',
        'coverage_depth',
        'coverage_notes',
        'publisher_name',
        'publication_type',
        'date_monograph_published_print',
        'date_monograph_published_online',
        'monograph_volume',
        'monograph_edition',
        'first_editor',
        'parent_publication_title_id',
        'preceding_publication_title_id',
        'access_type',
        'notes'
    );
}

=head3 calculate_chunked_file_size

Calculates average line size to work out how many lines to chunk a large file into
Knocks 10% off the final result to give some margin for error

=cut

sub calculate_chunked_file_size {
    my ( $file_size, $max_allowed_packet, $number_of_lines ) = @_;

    my $average_line_size = $file_size / $number_of_lines;
    my $lines_possible    = $max_allowed_packet / $average_line_size;
    my $moderated_value   = floor( $lines_possible * 0.9 );
    return $moderated_value;
}

1;
