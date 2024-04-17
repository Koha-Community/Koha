package Koha::ERM::EUsage::CounterFile;

# Copyright 2023 PTFS Europe

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

use Text::CSV_XS qw( csv );
use Try::Tiny;

use Koha::ERM::EUsage::CounterLog;
use Koha::ERM::EUsage::UsagePlatform;
use Koha::ERM::EUsage::UsagePlatforms;
use Koha::ERM::EUsage::UsageDatabase;
use Koha::ERM::EUsage::UsageDatabases;
use Koha::ERM::EUsage::UsageItem;
use Koha::ERM::EUsage::UsageItems;
use Koha::ERM::EUsage::UsageTitle;
use Koha::ERM::EUsage::UsageTitles;
use Koha::ERM::EUsage::UsageDataProvider;
use Koha::ERM::EUsage::SushiCounter;
use Koha::Exceptions::ERM::EUsage::CounterFile;

use C4::Context;

use base qw(Koha::Object);

use Koha::ERM::EUsage::CounterLogs;

=head1 NAME

Koha::ERM::EUsage::CounterFile - Koha ErmCounterFile Object class

=head1 API

=head2 Class Methods

=cut

=head3 counter_logs

Return the counter_logs for this counter_file

=cut

sub counter_logs {
    my ($self) = @_;

    my $counter_logs_rs = $self->_result->erm_counter_logs;
    return Koha::ERM::EUsage::CounterLogs->_new_from_dbic($counter_logs_rs);
}

=head3 store

    Koha::ERM::EUsage::CounterFile->new($counter_file)->store( $self->{job_callbacks} );

Stores the csv COUNTER file.
Adds usage titles from the file.
Adds the respective counter_log entry.

=over

=item background_job_callbacks

Receive background_job_callbacks to be able to update job progress

=back

=cut

sub store {
    my ( $self, $background_job_callbacks ) = @_;

    $self->_set_report_type_from_file;

    my $result = $self->SUPER::store;

    # Set class wide background_job callbacks
    $self->{job_callbacks} = $background_job_callbacks;

    $self->_add_usage_objects;
    $self->_add_counter_log_entry;

    return $result;
}

=head3 get_usage_data_provider

Getter for the usage data provider of this counter_file

=cut

sub get_usage_data_provider {
    my ($self) = @_;

    my $usage_data_provider = $self->_result->usage_data_provider;
    return Koha::ERM::EUsage::UsageDataProvider->_new_from_dbic($usage_data_provider);
}

=head2 Internal methods

=head3 _add_usage_objects

Goes through COUNTER file and adds usage objects for each row
A usage object may be a erm_usage_title, erm_usage_platform, erm_usage_item or erm_usage_database

#FIXME?: "Yearly" usage may be incorrect, it'll only add up the months in the current report, not necessarily the whole year

=cut

sub _add_usage_objects {
    my ($self) = @_;

    my $rows                = $self->_get_rows_from_COUNTER_file;
    my $usage_data_provider = $self->get_usage_data_provider;
    my $previous_object     = undef;
    my $usage_object        = undef;

    # Set job size to the amount of rows we're processing
    $self->{job_callbacks}->{set_size_callback}->( scalar( @{$rows} ) )
        if $self->{job_callbacks};
    foreach my $row ( @{$rows} ) {
        try {
            # INFO: A single row may have multiple instances in the COUNTER report, one for each metric_type or access_type or yop
            # If we're on a row that we've already gone through, use the same usage object
            # and add usage statistics for the different metric_type or access_type or yop
            if ( $self->_is_same_usage_object( $previous_object, $row ) ) {
                $usage_object = $previous_object;
            } else {

                # Check if usage object already exists in this data provider, e.g. from a previous harvest
                $usage_object = $self->_search_for_usage_object($row);

                if ($usage_object) {

                    # Usage object already exists, add job warning message and do nothing else
                    $self->_add_job_message(
                        'warning', 'object_already_exists',
                        $row
                    );
                } else {
                    try {
                        # Fresh usage object, create it
                        $usage_object = $self->_add_usage_object_entry($row);

                        # Usage object created, add job success message
                        $self->_add_job_message( 'success', 'object_added', $row );
                    } catch {
                        $self->_add_job_message(
                            'error', 'object_could_not_be_added',
                            $row
                        );
                        $self->{job_callbacks}->{step_callback}->() if $self->{job_callbacks};
                    };
                }
            }

            # Regex match for Mmm-yyyy expected format, e.g. "Jan 2022"
            my @date_fields =
                map( $_ =~ /\b[A-Z][a-z][a-z]\b [0-9]{4}\b/ ? $_ : (), keys %{$row} );

            unless (@date_fields) {
                warn "No monthly usage fields retrieved";
            }

            # Add monthly usage statistics for this usage object
            my %yearly_usages = ();
            foreach my $year_month (@date_fields) {
                my $usage = %{$row}{$year_month};

                # Skip this monthly usage entry if it's 0
                next if $usage eq "0";

                my $month = substr( $year_month, 0, 3 );
                my $year  = substr( $year_month, 4, 4 );

                if ( !exists $yearly_usages{$year} ) {
                    $yearly_usages{$year} = $usage;
                } else {
                    $yearly_usages{$year} += $usage;
                }

                $self->_add_monthly_usage_entries(
                    $usage_object,
                    $row->{Metric_Type}, $row, $year, $month, $usage
                );
            }

            # Add yearly usage statistics for this usage object
            $self->_add_yearly_usage_entries(
                $usage_object, $row->{Metric_Type},
                $row,          \%yearly_usages
            );

            $previous_object = $usage_object;

            # Update background job step
            $self->{job_callbacks}->{step_callback}->() if $self->{job_callbacks};
        } catch {
            warn $_;
        }
    }
}

=head3 _add_monthly_usage_entries

Adds erm_usage_mus database entries

=cut

sub _add_monthly_usage_entries {
    my ( $self, $usage_object, $metric_type, $row, $year, $month, $usage ) = @_;

    my $usage_data_provider = $self->get_usage_data_provider;
    my $usage_object_info   = $self->_get_usage_object_id_hash($usage_object);
    my $specific_fields     = Koha::ERM::EUsage::SushiCounter->get_report_type_specific_fields( $self->type );

    $usage_object->monthly_usages(
        [
            {
                %{$usage_object_info},
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
                year                   => $year,
                month                  => $self->_get_month_number($month),
                usage_count            => $usage,
                metric_type            => $row->{Metric_Type},
                grep ( /Access_Type/, @{$specific_fields} )
                ? ( access_type => $row->{Access_Type} )
                : (),
                grep ( /YOP/, @{$specific_fields} )
                ? ( yop => $row->{YOP} )
                : (),
                report_type => $self->type
            }
        ],
        $self->{job_callbacks}
    );
}

=head3 _add_yearly_usage_entries

Adds erm_usage_yus database entries

=cut

sub _add_yearly_usage_entries {
    my ( $self, $usage_object, $metric_type, $row, $yearly_usages ) = @_;

    my $usage_data_provider = $self->get_usage_data_provider;
    my $usage_object_info   = $self->_get_usage_object_id_hash($usage_object);
    my $specific_fields     = Koha::ERM::EUsage::SushiCounter->get_report_type_specific_fields( $self->type );

    while ( my ( $year, $usage ) = each( %{$yearly_usages} ) ) {

        # Skip this yearly usage entry if it's 0
        next if $usage eq "0";

        $usage_object->yearly_usages(
            [
                {
                    %{$usage_object_info},
                    usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
                    year                   => $year,
                    totalcount             => $usage,
                    metric_type            => $metric_type,
                    grep ( /Access_Type/, @{$specific_fields} )
                    ? ( access_type => $row->{Access_Type} )
                    : (),
                    grep ( /YOP/, @{$specific_fields} )
                    ? ( yop => $row->{YOP} )
                    : (),
                    report_type => $self->type
                }
            ],
            $self->{job_callbacks}
        );
    }
}

=head3 validate

Verifies if the given file_content is a valid COUNTER file or not

A I <Koha::Exceptions::ERM::EUsage::CounterFile> exception is thrown
    if the file is invalid .

=cut

sub validate {
    my ($self) = @_;

    open my $fh, "<", \$self->file_content or die;
    my $csv = Text::CSV_XS->new( { binary => 1, always_quote => 1, eol => $/, decode_utf8 => 1 } );

    $csv->column_names(qw( header_key header_value ));
    my @header_rows = $csv->getline_hr_all( $fh, 0, 12 );
    my @header      = $header_rows[0];

    my @release_row =
        map( $_->{header_key} eq 'Release' ? $_ : (), @{ $header[0] } );
    my $release = $release_row[0];

    # TODO: Validate that there is an empty row between header and body

    Koha::Exceptions::ERM::EUsage::CounterFile::UnsupportedRelease->throw
        if $release && $release->{header_value} != 5;

}

=head3 _set_report_type_from_file

Extracts Report_ID from file and sets report_type for this counter_file

=cut

sub _set_report_type_from_file {
    my ($self) = @_;

    open my $fh, "<", \$self->file_content or die;
    my $csv = Text::CSV_XS->new( { binary => 1, always_quote => 1, eol => $/, decode_utf8 => 1 } );

    $csv->column_names(qw( header_key header_value ));
    my @header_rows = $csv->getline_hr_all( $fh, 0, 12 );
    my @header      = $header_rows[0];

    my @report_id_row =
        map( $_->{header_key} eq 'Report_ID' ? $_ : (), @{ $header[0] } );
    my $report = $report_id_row[0];

    $self->type( $report->{header_value} );
}

=head3 _get_rows_from_COUNTER_file

Returns array of rows from COUNTER file

=cut

sub _get_rows_from_COUNTER_file {
    my ($self) = @_;

    open my $fh, "<", \$self->file_content or die;
    my $csv = Text::CSV_XS->new( { binary => 1, always_quote => 1, eol => $/, decode_utf8 => 1 } );

    my $header_columns = $csv->getline_all( $fh, 13, 1 );
    $csv->column_names( @{$header_columns}[0] );

    # Get all rows from 14th onward
    return $csv->getline_hr_all($fh);
}

=head3 _add_job_message

Add a message to be displayed in the background job

=cut

sub _add_job_message {
    my ( $self, $type, $code, $row ) = @_;

    my $usage_data_provider = $self->get_usage_data_provider;

    my $object_title;

    if ( $self->type =~ /PR/i ) {
        $object_title = $row->{Platform};
    } elsif ( $self->type =~ /DR/i ) {
        $object_title = $row->{Database};
    } elsif ( $self->type =~ /IR/i ) {
        $object_title = $row->{Item};
    } elsif ( $self->type =~ /TR/i ) {
        $object_title = $row->{Title};
    }

    $self->{job_callbacks}->{add_message_callback}->(
        {
            type  => $type,
            code  => $code,
            title => $object_title,
        }
    ) if $self->{job_callbacks};
}

=head3 _get_usage_object_id_hash

Return a usage_object id hash to be used when adding new yus/mus

=cut

sub _get_usage_object_id_hash {
    my ( $self, $usage_object ) = @_;

    if ( $self->type =~ /PR/i ) {
        return { platform_id => $usage_object->platform_id };
    } elsif ( $self->type =~ /DR/i ) {
        return { database_id => $usage_object->database_id };
    } elsif ( $self->type =~ /IR/i ) {
        return { item_id => $usage_object->item_id };
    } elsif ( $self->type =~ /TR/i ) {
        return { title_id => $usage_object->title_id };
    }
    return 0;
}

=head3 _search_for_usage_object

Returns usage object if found

=cut

sub _search_for_usage_object {
    my ( $self, $row ) = @_;

    my $usage_data_provider = $self->get_usage_data_provider;

    if ( $self->type =~ /PR/i ) {
        return Koha::ERM::EUsage::UsagePlatforms->search(
            {
                platform               => $row->{Platform},
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id
            }
        )->last;
    } elsif ( $self->type =~ /DR/i ) {
        return Koha::ERM::EUsage::UsageDatabases->search(
            {
                database               => $row->{Database},
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id
            }
        )->last;
    } elsif ( $self->type =~ /IR/i ) {
        return Koha::ERM::EUsage::UsageItems->search(
            {
                item                   => $row->{Item},
                publisher              => $row->{Publisher},
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id
            }
        )->last;
    } elsif ( $self->type =~ /TR/i ) {
        return Koha::ERM::EUsage::UsageTitles->search(
            {
                print_issn             => $row->{Print_ISSN},
                online_issn            => $row->{Online_ISSN},
                proprietary_id         => $row->{Proprietary_ID},
                publisher              => $row->{Publisher},
                platform               => $row->{Platform},
                title                  => $row->{Title},
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id
            }
        )->last;
    }

    return 0;
}

=head3 _is_same_usage_object

Returns true if is the same usage object

=cut

sub _is_same_usage_object {
    my ( $self, $previous_object, $row ) = @_;

    if ( $self->type =~ /PR/i ) {
        return $previous_object
            && $previous_object->platform eq $row->{Platform};
    } elsif ( $self->type =~ /DR/i ) {
        return $previous_object
            && $previous_object->database eq $row->{Database};
    } elsif ( $self->type =~ /IR/i ) {
        return
               $previous_object
            && $previous_object->item eq $row->{Item}
            && $previous_object->publisher eq $row->{Publisher};
    } elsif ( $self->type =~ /TR/i ) {

        return unless $previous_object;

        if ( $previous_object->print_issn && $row->{Print_ISSN} ) {
            return unless $previous_object->print_issn eq $row->{Print_ISSN};
        }

        if ( $previous_object->online_issn && $row->{Online_ISSN} ) {
            return unless $previous_object->online_issn eq $row->{Online_ISSN};
        }

        if ( $previous_object->proprietary_id && $row->{Proprietary_ID} ) {
            return unless $previous_object->proprietary_id eq $row->{Proprietary_ID};
        }

        if ( $previous_object->publisher && $row->{Publisher} ) {
            return unless $previous_object->publisher eq $row->{Publisher};
        }

        if ( $previous_object->platform && $row->{Platform} ) {
            return unless $previous_object->platform eq $row->{Platform};
        }

        if ( $previous_object->title_doi && $row->{DOI} ) {
            return unless $previous_object->title_doi eq $row->{DOI};
        }

        if ( $previous_object->title && $row->{Title} ) {
            return unless $previous_object->title eq $row->{Title};
        }

        return 1;
    }

    return 0;
}

=head3 _get_month_number

Returns month number for a given Mmm month

=cut

sub _get_month_number {
    my ( $self, $month ) = @_;

    my %months = (
        "Jan" => 1,
        "Feb" => 2,
        "Mar" => 3,
        "Apr" => 4,
        "May" => 5,
        "Jun" => 6,
        "Jul" => 7,
        "Aug" => 8,
        "Sep" => 9,
        "Oct" => 10,
        "Nov" => 11,
        "Dec" => 12
    );

    return $months{$month};
}

=head3 _add_counter_log_entry

Adds a erm_counter_logs database entry

=cut

sub _add_counter_log_entry {
    my ($self) = @_;

    my $user = C4::Context->userenv()->{'number'};
    Koha::ERM::EUsage::CounterLog->new(
        {
            #TODO: borrowernumber only required for manual uploads or "harvest now" button clicks
            borrowernumber   => $user,
            counter_files_id => $self->erm_counter_files_id,
            importdate       => $self->date_uploaded,
            filename         => $self->filename,

            #TODO: add eventual exceptions coming from the COUNTER report to logdetails?
            logdetails => undef,

            # TEST: retrieving counter logs directly rather than embedding them in counter files requires the provider id
            usage_data_provider_id => $self->usage_data_provider_id
        }
    )->store;
}

=head3 _add_usage_object_entry

Adds a usage object database entry

=cut

sub _add_usage_object_entry {
    my ( $self, $row ) = @_;

    my $usage_data_provider = $self->get_usage_data_provider;
    my $specific_fields     = Koha::ERM::EUsage::SushiCounter->get_report_type_specific_fields( $self->type );

    if ( $self->type =~ /PR/i ) {
        my $new_usage_platform = Koha::ERM::EUsage::UsagePlatform->new(
            {
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
                platform               => $row->{Platform},
            }
        )->store;

        $self->{job_callbacks}->{report_info_callback}->('added_usage_objects')
            if $self->{job_callbacks} && $new_usage_platform;

        return $new_usage_platform;
    } elsif ( $self->type =~ /DR/i ) {
        my $new_usage_database = Koha::ERM::EUsage::UsageDatabase->new(
            {
                database               => $row->{Database},
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
                platform               => $row->{Platform},
                publisher              => $row->{Publisher},
                publisher_id           => $row->{Publisher_ID},
            }
        )->store;

        $self->{job_callbacks}->{report_info_callback}->('added_usage_objects')
            if $self->{job_callbacks} && $new_usage_database;

        return $new_usage_database;
    } elsif ( $self->type =~ /IR/i ) {
        my $new_usage_item = Koha::ERM::EUsage::UsageItem->new(
            {
                item                   => $row->{Item},
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
                platform               => $row->{Platform},
                publisher              => $row->{Publisher},
            }
        )->store;

        $self->{job_callbacks}->{report_info_callback}->('added_usage_objects')
            if $self->{job_callbacks} && $new_usage_item;

        return $new_usage_item;
    } elsif ( $self->type =~ /TR/i ) {
        my $new_usage_title = Koha::ERM::EUsage::UsageTitle->new(
            {
                title                  => $row->{Title},
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
                title_doi              => $row->{DOI},
                proprietary_id         => $row->{Proprietary_ID},
                platform               => $row->{Platform},
                print_issn             => $row->{Print_ISSN},
                online_issn            => $row->{Online_ISSN},
                title_uri              => $row->{URI},
                publisher              => $row->{Publisher},
                publisher_id           => $row->{Publisher_ID},
                grep ( /ISBN/, @{$specific_fields} )
                ? ( isbn => $row->{ISBN} )
                : (),
            }
        )->store;

        $self->{job_callbacks}->{report_info_callback}->('added_usage_objects')
            if $self->{job_callbacks} && $new_usage_title;

        return $new_usage_title;
    }
}

=head3 _type

=cut

sub _type {
    return 'ErmCounterFile';
}

1;
