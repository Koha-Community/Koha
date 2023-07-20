package Koha::ERM::UsageDataProvider;

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

use HTTP::Request;
use JSON qw( decode_json );
use LWP::UserAgent;
use Text::CSV_XS qw( csv );

use Koha::Exceptions;

use base qw(Koha::Object);

use Koha::ERM::CounterFile;
use Koha::ERM::CounterFiles;
use Koha::BackgroundJob::ErmSushiHarvester;

=head1 NAME

Koha::ERM::UsageDataProvider - Koha ErmUsageDataProvider Object class

=head1 API

=head2 Class Methods

=head3 counter_files

Getter/setter for counter_files for this usage data provider

=cut

sub counter_files {
    my ( $self, $counter_files ) = @_;

    if ($counter_files) {
        for my $counter_file (@$counter_files) {
            Koha::ERM::CounterFile->new($counter_file)
              ->store( $self->{job_callbacks} );
        }
    }
    my $counter_files_rs = $self->_result->erm_counter_files;
    return Koha::ERM::CounterFiles->_new_from_dbic($counter_files_rs);
}

=head3 enqueue_counter_file_processing_job

Enqueues a background job to process a COUNTER file that has been uploaded

=cut

sub enqueue_counter_file_processing_job {
    my ( $self, $args ) = @_;

    my @jobs;
    my $job_id = Koha::BackgroundJob::ErmSushiHarvester->new->enqueue(
        {
            ud_provider_id => $self->erm_usage_data_provider_id,
            file_content   => $args->{file_content},
        }
    );

    push(
        @jobs,
        {
            job_id => $job_id
        }
    );

    return \@jobs;
}

=head3 enqueue_sushi_harvest_jobs

Enqueues one harvest background job for each report type in this usage data provider

=cut

sub enqueue_sushi_harvest_jobs {
    my ( $self, $args ) = @_;

    my @report_types = split( /;/, $self->report_types );

    my @jobs;
    foreach my $report_type (@report_types) {

        my $job_id = Koha::BackgroundJob::ErmSushiHarvester->new->enqueue(
            {
                ud_provider_id => $self->erm_usage_data_provider_id,
                report_type    => $report_type
            }
        );

        push(
            @jobs,
            {
                report_type => $report_type,
                job_id      => $job_id
            }
        );
    }

    return \@jobs;
}

=head3 harvest

    $ud_provider->harvest(
        {
            step_callback        => sub { $self->step; },
            set_size_callback    => sub { $self->set_job_size(@_); },
            add_message_callback => sub { $self->add_message(@_); },
        }
    );

Run the SUSHI harvester of this usage data provider
Builds the URL query and requests the COUNTER 5 SUSHI service

COUNTER SUSHI api spec:
https://app.swaggerhub.com/apis/COUNTER/counter-sushi_5_0_api/5.0.2

=over

=item report_type

Report type to run this harvest on

=back

=over

=item background_job_callbacks

Receive background_job_callbacks to be able to update job

=back

=cut

sub harvest {
    my ( $self, $report_type, $background_job_callbacks ) = @_;

    # Set class wide vars
    $self->{job_callbacks} = $background_job_callbacks;
    $self->{report_type} = $report_type;

    my $url      = $self->_build_url_query;
    my $request  = HTTP::Request->new( 'GET' => $url );
    my $ua       = LWP::UserAgent->new;
    my $response = $ua->simple_request($request);

    if ( $response->code >= 400 ) {
        my $result = decode_json( $response->decoded_content );

        my $message;
        if ( ref($result) eq 'ARRAY' ) {
            for my $r (@$result) {
                $message .= $r->{message};
            }
        }
        else {
            #TODO: May want to check $result->{Report_Header}->{Exceptions} here
            $message = $result->{message} || $result->{Message} || q{};
            if ( $result->{errors} ) {
                for my $e ( @{ $result->{errors} } ) {
                    $message .= $e->{message};
                }
            }
        }

        #TODO: May want to add a job error message here?
        warn sprintf "ERROR - SUSHI service %s returned %s - %s\n", $url,
          $response->code, $message;
        if ( $response->code == 404 ) {
            Koha::Exceptions::ObjectNotFound->throw($message);
        }
        elsif ( $response->code == 401 ) {
            Koha::Exceptions::Authorization::Unauthorized->throw($message);
        }
        else {
            #TODO: May want to add a job error message here?
            die sprintf "ERROR requesting SUSHI service\n%s\ncode %s: %s\n",
              $url, $response->code,
              $message;
        }
    }
    elsif ( $response->code == 204 ) {    # No content
        return;
    }

    # Parse the SUSHI response
    $self->parse_SUSHI_response( decode_json( $response->decoded_content ) );
}

=head3 parse_SUSHI_response

    $self->parse_SUSHI_response( decode_json( $response->decoded_content ) );

Parse the SUSHI response, prepare the COUNTER report file header,
column headings and body

=over

=item result

The result of the SUSHI response after json decoded

=back

=cut

sub parse_SUSHI_response {
    my ( $self, $result ) = @_;

    # Set class wide sushi response content
    $self->{sushi} = {
        header => $result->{Report_Header},
        body   => $result->{Report_Items}
    };

    #TODO: Handle empty $self->{sushi}->{body} here!

    # Get ready to build COUNTER file
    my @report_header          = $self->_COUNTER_report_header;
    my @report_column_headings = $self->_COUNTER_report_column_headings;
    my @report_body            = $self->_COUNTER_report_body;

    $self->_build_COUNTER_report_file( \@report_header,
        \@report_column_headings, \@report_body );
}

=head2 Internal methods

=head3 _build_url_query

Build the URL query params for COUNTER 5 SUSHI request

=cut

sub _build_url_query {
    my ($self) = @_;

    unless ( $self->service_url && $self->customer_id ) {
        die sprintf
"SUSHI Harvesting config for usage data provider %d is missing service_url or customer_id\n",
          $self->erm_usage_data_provider_id;
    }

    # FIXME: service_url needs to end in 'reports/'
    # below concat will result in a badly formed URL otherwise
    # Either validate this on UI form, here, or both
    my $url = $self->service_url;

    $url .= $self->{report_type};
    $url .= '?customer_id=' . $self->customer_id;
    $url .= '&requestor_id=' . $self->requestor_id if $self->requestor_id;
    $url .= '&api_key=' . $self->api_key           if $self->api_key;
    $url .= '&begin_date=' . $self->begin_date     if $self->begin_date;
    $url .= '&end_date=' . $self->end_date         if $self->end_date;

    return $url;
}

=head3 _build_COUNTER_report_file

Build the COUNTER file
https://cop5.projectcounter.org/en/5.0.2/03-specifications/02-formats-for-counter-reports.html#report-header

=cut

sub _build_COUNTER_report_file {
    my ( $self, $header, $column_headings, $body ) = @_;

    my @report = ( @{$header}, @{$column_headings}, @{$body} );

    #TODO: change this to tab instead of comma
    csv( in => \@report, out => \my $counter_file, encoding => "utf-8" );

    $self->counter_files(
        [
            {
                usage_data_provider_id => $self->erm_usage_data_provider_id,
                file_content           => $counter_file,
                date_uploaded => POSIX::strftime( "%Y%m%d%H%M%S", localtime ),

                #TODO: add ".csv" to end of filename here
                filename => $self->name . "_" . $self->{report_type},
            }
        ]
    );
}

=head3 _COUNTER_report_header

Return a COUNTER report header
https://cop5.projectcounter.org/en/5.0.2/04-reports/03-title-reports.html

=cut

sub _COUNTER_report_header {
    my ($self) = @_;

    my $header = $self->{sushi}->{header};

    my @metric_types_string =
      $self->_get_SUSHI_Name_Value( $header->{Report_Filters}, "Metric_Type" );

    my $begin_date =
      $self->_get_SUSHI_Name_Value( $header->{Report_Filters}, "Begin_Date" );
    my $end_date =
      $self->_get_SUSHI_Name_Value( $header->{Report_Filters}, "End_Date" );

    return (
        [ Report_Name      => $header->{Report_Name}      || "" ],
        [ Report_ID        => $header->{Report_ID}        || "" ],
        [ Release          => $header->{Release}          || "" ],
        [ Institution_Name => $header->{Institution_Name} || "" ],
        [
            Institution_ID => join(
                "; ",
                map( $_->{Type} . ":" . $_->{Value},
                    @{ $header->{Institution_ID} } )
              )
              || ""
        ],
        [
            Metric_Types => join( "; ", split( /\|/, $metric_types_string[0] ) )
              || ""
        ],
        [
            Report_Filters => join(
                "; ",
                map( $_->{Name} . ":" . $_->{Value},
                    @{ $header->{Report_Filters} } )
              )
              || ""
        ],

#TODO: Report_Attributes may need parsing, test this with a SUSHI response that provides it
        [ Report_Attributes => $header->{Report_Attributes} || "" ],
        [
            Exceptions => join(
                "; ",
                map( $_->{Code} . ": "
                      . $_->{Message} . " ("
                      . $_->{Data} . ")",
                    @{ $header->{Exceptions} } )
              )
              || ""
        ],
        [
                Reporting_Period => "Begin_Date="
              . $begin_date
              . "; End_Date="
              . $end_date
        ],
        [ Created    => $header->{Created}    || "" ],
        [ Created_By => $header->{Created_By} || "" ],
        [""]    #empty 13th line
    );
}

=head3 _COUNTER_item_report_row

Return a COUNTER item for the COUNTER items report body
https://cop5.projectcounter.org/en/5.0.2/04-reports/04-item-reports.html#column-headings-elements

=cut

sub _COUNTER_item_report_row {
    my ( $self, $item_row, $metric_type, $total_usage, $monthly_usages ) = @_;

    return (
        [
            $item_row->{Item}      || "",
            $item_row->{Publisher} || "",
            $self->_get_SUSHI_Type_Value( $item_row->{Publisher_ID}, "ISNI" )
              || "",
            $item_row->{Platform}                                       || "",
            $self->_get_SUSHI_Type_Value( $item_row->{Item_ID}, "DOI" ) || "",
            $item_row->{Proprietary_ID}                                 || "",
            "",    #FIXME: What goes in URI?
            $metric_type,
            $total_usage,
            @{$monthly_usages}
        ]
    );
}

=head3 _COUNTER_database_report_row

Return a COUNTER database for the COUNTER databases report body
https://cop5.projectcounter.org/en/5.0.2/04-reports/02-database-reports.html#column-headings-elements

=cut

sub _COUNTER_database_report_row {
    my ( $self, $database_row, $metric_type, $total_usage, $monthly_usages ) =
      @_;

    return (
        [
            $database_row->{Database}  || "",
            $database_row->{Publisher} || "",
            $self->_get_SUSHI_Type_Value( $database_row->{Publisher_ID},
                "ISNI" )
              || "",
            $database_row->{Platform}       || "",
            $database_row->{Proprietary_ID} || "",
            $metric_type,
            $total_usage,
            @{$monthly_usages}
        ]
    );
}

=head3 _COUNTER_platform_report_row

Return a COUNTER platform for the COUNTER platforms report body
https://cop5.projectcounter.org/en/5.0.2/04-reports/01-platform-reports.html#column-headings-elements

=cut

sub _COUNTER_platform_report_row {
    my ( $self, $platform_row, $metric_type, $total_usage, $monthly_usages ) =
      @_;

    return (
        [
            $platform_row->{Platform} || "", $metric_type,
            $total_usage,                    @{$monthly_usages}
        ]
    );
}

=head3 _COUNTER_title_report_row

Return a COUNTER title for the COUNTER titles report body
https://cop5.projectcounter.org/en/5.0.2/04-reports/03-title-reports.html#column-headings-elements

=cut

sub _COUNTER_title_report_row {
    my ( $self, $title_row, $metric_type, $total_usage, $monthly_usages ) = @_;

    my $header = $self->{sushi}->{header};
    my $specific_fields =
      $self->get_report_type_specific_fields( $header->{Report_ID} );

    return (
        [
            # Title
            $title_row->{Title} || "",

            # Publisher
            $title_row->{Publisher} || "",

            # Publisher_ID
            $self->_get_SUSHI_Type_Value( $title_row->{Publisher_ID}, "ISNI" )
              || "",

            # Platform
            $title_row->{Platform} || "",

            # DOI
            $self->_get_SUSHI_Type_Value( $title_row->{Item_ID}, "DOI" ) || "",

            # Proprietary_ID
            $self->_get_SUSHI_Type_Value(
                $title_row->{Item_ID}, "Proprietary"
              )
              || "",

            # ISBN
            grep ( /ISBN/, @{$specific_fields} )
            ? ( $self->_get_SUSHI_Type_Value( $title_row->{Item_ID}, "ISBN" )
                  || "" )
            : (),

            # Print_ISSN
            $self->_get_SUSHI_Type_Value( $title_row->{Item_ID}, "Print_ISSN" )
              || "",

            # Online_ISSN
            $self->_get_SUSHI_Type_Value(
                $title_row->{Item_ID}, "Online_ISSN"
              )
              || "",

            # URI - FIXME: What goes in URI?
            "",

            # YOP
            grep ( /YOP/, @{$specific_fields} )
            ? ( $title_row->{YOP} || "" )
            : (),

            # Access_Type
            grep ( /Access_Type/, @{$specific_fields} )
            ? ( $title_row->{Access_Type} || "" )
            : (),

            # Metric_Type
            $metric_type,

            # Report_Period_Total
            $total_usage,

            # Monthly usage entries
            @{$monthly_usages}
        ]
    );
}

=head3 _COUNTER_report_row

Return a COUNTER row for the COUNTER report body

=cut

sub _COUNTER_report_row {
    my ( $self, $report_row, $metric_type ) = @_;

    my $header = $self->{sushi}->{header};

    my ( $total_usage, @monthly_usages ) =
      $self->_get_row_usages( $report_row, $metric_type );

    if ( $header->{Report_ID} =~ /PR/i ) {
        return $self->_COUNTER_platform_report_row( $report_row, $metric_type,
            $total_usage, \@monthly_usages );
    }
    elsif ( $header->{Report_ID} =~ /DR/i ) {
        return $self->_COUNTER_database_report_row( $report_row, $metric_type,
            $total_usage, \@monthly_usages );
    }
    elsif ( $header->{Report_ID} =~ /IR/i ) {
        return $self->_COUNTER_item_report_row( $report_row, $metric_type,
            $total_usage, \@monthly_usages );
    }
    elsif ( $header->{Report_ID} =~ /TR/i ) {
        return $self->_COUNTER_title_report_row( $report_row, $metric_type,
            $total_usage, \@monthly_usages );
    }
}

=head3 _get_row_usages

Returns the total and monthly usages for a row

=cut

sub _get_row_usages {
    my ( $self, $row, $metric_type ) = @_;

    my @usage_months = $self->_get_usage_months( $self->{sushi}->{header} );

    my @usage_months_fields = ();
    my $count_total         = 0;

    foreach my $usage_month (@usage_months) {
        my $month_is_empty = 1;

        foreach my $performance ( @{ $row->{Performance} } ) {
            my $period             = $performance->{Period};
            my $period_usage_month = substr( $period->{Begin_Date}, 0, 7 );

            my $instances = $performance->{Instance};
            my @metric_type_count =
              map( $_->{Metric_Type} eq $metric_type ? $_->{Count} : (),
                @{$instances} );

            if ( $period_usage_month eq $usage_month && $metric_type_count[0] )
            {
                push( @usage_months_fields, $metric_type_count[0] );
                $count_total += $metric_type_count[0];
                $month_is_empty = 0;
            }
        }

        if ($month_is_empty) {
            push( @usage_months_fields, 0 );
        }
    }
    return ( $count_total, @usage_months_fields );
}

=head3 _COUNTER_report_body

Return the COUNTER report body as an array

=cut

sub _COUNTER_report_body {
    my ($self) = @_;

    my $header = $self->{sushi}->{header};
    my $body   = $self->{sushi}->{body};

    my @metric_types_string = $self->_get_SUSHI_Name_Value( $header->{Report_Filters}, "Metric_Type" );
    my @metric_types        = split( /\|/, $metric_types_string[0] );

    my @report_body = ();

    my $total_records = 0;
    foreach my $report_row ( @{$body} ) {

        my @metric_types = ();

        # Grab all metric_types this SUSHI result has statistics for
        foreach my $performance ( @{ $report_row->{Performance} } ) {
            my @SUSHI_metric_types =
              map( $_->{Metric_Type}, @{ $performance->{Instance} } );

            foreach my $sushi_metric_type (@SUSHI_metric_types) {
                push( @metric_types, $sushi_metric_type )
                  unless grep { $_ eq $sushi_metric_type } @metric_types;
            }
        }

        # Add one report row for each metric_type we're working with
        foreach my $metric_type (@metric_types) {
            push( @report_body,
                $self->_COUNTER_report_row( $report_row, $metric_type ) );
        }
        $self->{total_records} = ++$total_records;
    }

    return @report_body;
}

=head3 _get_SUSHI_Name_Value

Returns "Value" of a given "Name"

=cut

sub _get_SUSHI_Name_Value {
    my ( $self, $item, $name ) = @_;

    my @value = map( $_->{Name} eq $name ? $_->{Value} : (), @{$item} );

    return $value[0];
}

=head3 _get_SUSHI_Type_Value

Returns "Value" of a given "Type"

=cut

sub _get_SUSHI_Type_Value {
    my ( $self, $item, $type ) = @_;

    my @value = map( $_->{Type} eq $type ? $_->{Value} : (), @{$item} );

    return $value[0];
}

=head3 _COUNTER_report_column_headings

Returns column headings by report type
  Check the report type from the COUNTER header
  and return column headings accordingly

=cut

sub _COUNTER_report_column_headings {
    my ($self) = @_;

    my $header = $self->{sushi}->{header};

    if ( $header->{Report_ID} =~ /PR/i ) {
        return $self->_COUNTER_platforms_report_column_headings;
    }
    elsif ( $header->{Report_ID} =~ /DR/i ) {
        return $self->_COUNTER_databases_report_column_headings;
    }
    elsif ( $header->{Report_ID} =~ /IR/i ) {
        return $self->_COUNTER_items_report_column_headings;
    }
    elsif ( $header->{Report_ID} =~ /TR/i ) {
        return $self->_COUNTER_titles_report_column_headings;
    }

    return;
}

=head3 _COUNTER_items_report_column_headings

Return items report column headings

=cut

sub _COUNTER_items_report_column_headings {
    my ($self) = @_;

    my $header         = $self->{sushi}->{header};
    my @month_headings = $self->_get_usage_months( $header, 1 );

    return (
        [
            "Item",
            "Publisher",
            "Publisher_ID",
            "Platform",

            # "Authors", #IR_A1 only
            # "Publication_Date", #IR_A1 only
            # "Article_Version", #IR_A1 only
            "DOI",
            "Proprietary_ID",

            # "ISBN", #IR only
            # "Print_ISSN", #IR_A1 only
            # "Online_ISSN", #IR_A1 only
            "URI",

            # "Parent_Title", #IR_A1 only
            # "Parent_Authors", #IR_A1 only
            # "Parent_Publication_Date", #IR only
            # "Parent_Article_Version", #IR_A1 only
            # "Parent_Data_Type", #IR only
            # "Parent_DOI", #IR_A1 only
            # "Parent_Proprietary_ID", #IR_A1 only
            # "Parent_ISBN", #IR only
            # "Parent_Print_ISSN", #IR_A1 only
            # "Parent_Online_ISSN", #IR_A1 only
            # "Parent_URI", #IR_A1 only
            # "Component_Title", #IR only
            # "Component_Authors", #IR only
            # "Component_Publication_Date", #IR only
            # "Component_Data_Type", #IR only
            # "Component_DOI", #IR only
            # "Component_Proprietary_ID", #IR only
            # "Component_ISBN", #IR only
            # "Component_Print_ISSN", #IR only
            # "Component_Online_ISSN", #IR only
            # "Component_URI", #IR only
            # "Data_Type", #IR only
            # "YOP", #IR only
            # "Access_Type", #IR_A1 only
            # "Access_Method", #IR only
            "Metric_Type",
            "Reporting_Period_Total",

# @month_headings in "Mmm-yyyy" format. TODO: Show unless Exclude_Monthly_Details=true
            @month_headings
        ]
    );
}

=head3 _COUNTER_databases_report_column_headings

Return databases report column headings

=cut

sub _COUNTER_databases_report_column_headings {
    my ($self) = @_;

    my $header         = $self->{sushi}->{header};
    my @month_headings = $self->_get_usage_months( $header, 1 );

    return (
        [
            "Database",
            "Publisher",
            "Publisher_ID",
            "Platform",
            "Proprietary_ID",
            "Metric_Type",
            "Reporting_Period_Total",

# @month_headings in "Mmm-yyyy" format. TODO: Show unless Exclude_Monthly_Details=true
            @month_headings
        ]
    );
}

=head3 _COUNTER_platforms_report_column_headings

Return platforms report column headings

=cut

sub _COUNTER_platforms_report_column_headings {
    my ($self) = @_;

    my $header         = $self->{sushi}->{header};
    my @month_headings = $self->_get_usage_months( $header, 1 );

    return (
        [
            "Platform",
            "Metric_Type",
            "Reporting_Period_Total",

# @month_headings in "Mmm-yyyy" format. TODO: Show unless Exclude_Monthly_Details=true
            @month_headings
        ]
    );
}

=head3 _COUNTER_titles_report_column_headings

Return titles report column headings

=cut

sub _COUNTER_titles_report_column_headings {
    my ($self) = @_;

    my $header         = $self->{sushi}->{header};
    my @month_headings = $self->_get_usage_months( $header, 1 );
    my $specific_fields =
      $self->get_report_type_specific_fields( $header->{Report_ID} );

    return (
        [
            "Title",
            "Publisher",
            "Publisher_ID",
            "Platform",
            "DOI",
            "Proprietary_ID",
            grep ( /ISBN/, @{$specific_fields} ) ? ("ISBN") : (),
            "Print_ISSN",
            "Online_ISSN",
            "URI",

            #"Data_Type", #TODO: Only if requested (?)
            #"Section_Type", #TODO: Only if requested (?)
            grep ( /YOP/,         @{$specific_fields} ) ? ("YOP")         : (),
            grep ( /Access_Type/, @{$specific_fields} ) ? ("Access_Type") : (),

            #"Access_Method", #TODO: Only if requested (?)
            "Metric_Type",
            "Reporting_Period_Total",

# @month_headings in "Mmm-yyyy" format. TODO: Show unless Exclude_Monthly_Details=true
            @month_headings
        ]
    );
}

=head3 _get_usage_months

Return report usage months. Formatted for column headings if $column_headings_formatting

=cut

sub _get_usage_months {
    my ( $self, $header, $column_headings_formatting ) = @_;

    my @months = (
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    );

    my @begin_date = map( $_->{Name} eq "Begin_Date" ? $_->{Value} : (),
        @{ $header->{Report_Filters} } );
    my $begin_month = substr( $begin_date[0], 5, 2 );
    my $begin_year  = substr( $begin_date[0], 0, 4 );

    my @end_date = map( $_->{Name} eq "End_Date" ? $_->{Value} : (),
        @{ $header->{Report_Filters} } );
    my $end_month = substr( $end_date[0], 5, 2 );
    my $end_year  = substr( $end_date[0], 0, 4 );

    my @month_headings = ();
    while ( $begin_month <= $end_month || $begin_year < $end_year ) {
        push( @month_headings,
              $column_headings_formatting
            ? $months[ $begin_month - 1 ] . " " . $begin_year
            : $begin_year . "-" . $begin_month );
        $begin_month++;
        if ( $begin_month > 12 ) {
            $begin_month = 1;
            $begin_year++;
        }
        $begin_month = "0" . $begin_month if length($begin_month) == 1;
    }

    return @month_headings;
}

=head3 get_report_type_specific_fields

Returns the specific fields for a given report_type

=cut

sub get_report_type_specific_fields {
    my ( $self, $report_type ) = @_;

    my %report_type_map = (
        "TR_B1" => [ 'YOP', 'ISBN' ],
        "TR_B2" => [ 'YOP', 'ISBN' ],
        "TR_B3" => [ 'YOP', 'Access_Type', 'ISBN' ],
        "TR_J3" => ['Access_Type'],
        "TR_J4" => ['YOP'],
    );

    return $report_type_map{$report_type};

}

=head3 test_connection

Tests the connection of the harvester to the SUSHI service and returns any alerts of planned SUSHI outages

=cut

sub test_connection {
    my ($self) = @_;

    my $url = $self->service_url;
    $url .= '/status';
    $url .= '?customer_id=' . $self->customer_id;
    $url .= '&requestor_id=' . $self->requestor_id if $self->requestor_id;
    $url .= '&api_key=' . $self->api_key           if $self->api_key;

    my $request  = HTTP::Request->new( 'GET' => $url );
    my $ua       = LWP::UserAgent->new;
    my $response = $ua->simple_request($request);

    my @result = decode_json( $response->decoded_content );
    if ( $result[0][0]->{Service_Active} ) {
        return 1;
    }
    else {
        return 0;
    }

}

=head3 erm_usage_titles

Method to embed erm_usage_titles to titles for report formatting

=cut

sub erm_usage_titles {
    my ($self) = @_;
    my $usage_title_rs = $self->_result->erm_usage_titles;
    return Koha::ERM::UsageTitles->_new_from_dbic($usage_title_rs);
}

=head3 erm_usage_muses

Method to embed erm_usage_muses to titles for report formatting

=cut

sub erm_usage_muses {
    my ($self) = @_;
    my $usage_mus_rs = $self->_result->erm_usage_muses;
    return Koha::ERM::MonthlyUsages->_new_from_dbic($usage_mus_rs);
}



=head3 _type

=cut

sub _type {
    return 'ErmUsageDataProvider';
}

1;
