package Koha::ERM::EUsage::COUNTER::5;

# Copyright 2025 Open Fifth

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

use base qw(Koha::ERM::EUsage::SushiCounter);

=head1 NAME

Koha::ERM::EUsage::COUNTER::5 - Koha COUNTER 5 Object class

=head1 API

=head2 Class Methods

=head3 new

    my $sushi_counter =
        Koha::ERM::EUsage::SushiCounter->new( { response => decode_json( $response->decoded_content ) } );

=cut

sub new {
    my ($class) = @_;
    my $self = {};

    bless( $self, $class );
}

=head3 _COUNTER_report_header

Return a COUNTER report header
https://cop5.projectcounter.org/en/5.0.2/04-reports/03-title-reports.html

=cut

sub _COUNTER_report_header {
    my ($self) = @_;

    my $header = $self->{sushi}->{header};

    my @metric_types_string = $self->_get_SUSHI_Name_Value( $header->{Report_Filters}, "Metric_Type" );

    my $begin_date = $self->_get_SUSHI_Name_Value( $header->{Report_Filters}, "Begin_Date" );
    my $end_date   = $self->_get_SUSHI_Name_Value( $header->{Report_Filters}, "End_Date" );

    return (
        [ Report_Name      => $header->{Report_Name}                                                            || "" ],
        [ Report_ID        => $header->{Report_ID}                                                              || "" ],
        [ Release          => $header->{Release}                                                                || "" ],
        [ Institution_Name => $header->{Institution_Name}                                                       || "" ],
        [ Institution_ID => join( "; ", map( $_->{Type} . ":" . $_->{Value}, @{ $header->{Institution_ID} } ) ) || "" ],
        [ Metric_Types   => join( "; ", split( /\|/, $metric_types_string[0] ) )                                || "" ],
        [ Report_Filters => join( "; ", map( $_->{Name} . ":" . $_->{Value}, @{ $header->{Report_Filters} } ) ) || "" ],

        #TODO: Report_Attributes may need parsing, test this with a SUSHI response that provides it
        [ Report_Attributes => $header->{Report_Attributes} || "" ],
        [
            Exceptions => join(
                "; ", map( $_->{Code} . ": " . $_->{Message} . " (" . $_->{Data} . ")", @{ $header->{Exceptions} } )
                )
                || ""
        ],
        [ Reporting_Period => "Begin_Date=" . $begin_date . "; End_Date=" . $end_date ],
        [ Created          => $header->{Created}    || "" ],
        [ Created_By       => $header->{Created_By} || "" ],
        [""]    #empty 13th line (COUNTER 5)
    );
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

=head3 _get_COUNTER_row_usages

Returns the total and monthly usages for a row

=cut

sub _get_COUNTER_row_usages {
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

            if ( $period_usage_month eq $usage_month && $metric_type_count[0] ) {
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

=head3 get_SUSHI_metric_types

    Returns all metric types this SUSHI result has statistics for, as an array of strings.

=cut

sub get_SUSHI_metric_types {
    my ( $self, $report_row ) = @_;

    my @metric_types = ();

    # Grab all metric_types this SUSHI result has statistics for
    foreach my $performance ( @{ $report_row->{Performance} } ) {
        my @SUSHI_metric_types =
            map( $_->{Metric_Type}, @{ $performance->{Instance} } );

        foreach my $sushi_metric_type (@SUSHI_metric_types) {
            push( @metric_types, $sushi_metric_type ) unless grep { $_ eq $sushi_metric_type } @metric_types;
        }
    }

    return @metric_types;
}

=head3 _COUNTER_report_body

Return the COUNTER report body as an array

=cut

sub _COUNTER_report_body {
    my ($self) = @_;

    my $header = $self->{sushi}->{header};
    my $body   = $self->{sushi}->{body};

    my @report_body = ();

    foreach my $report_row ( @{$body} ) {
        my @metric_types = $self->get_SUSHI_metric_types($report_row);

        # Add one report row for each metric_type we're working with
        foreach my $metric_type (@metric_types) {
            push( @report_body, $self->_COUNTER_report_row( $report_row, $metric_type ) );
        }
    }

    return @report_body;
}

=head3 _COUNTER_title_report_row

Return a COUNTER title for the COUNTER titles report body
https://cop5.projectcounter.org/en/5.0.2/04-reports/03-title-reports.html#column-headings-elements

=cut

sub _COUNTER_title_report_row {
    my ( $self, $title_row, $metric_type, $total_usage, $monthly_usages ) = @_;

    my $header          = $self->{sushi}->{header};
    my $specific_fields = $self->get_report_type_specific_fields( $header->{Report_ID} );

    return (
        [
            # Title
            $title_row->{Title} || "",

            # Publisher
            $title_row->{Publisher} || "",

            # Publisher_ID
            $self->_get_SUSHI_Type_Value( $title_row->{Publisher_ID}, "ISNI" ) || "",

            # Platform
            $title_row->{Platform} || "",

            # DOI
            $self->_get_SUSHI_Type_Value( $title_row->{Item_ID}, "DOI" ) || "",

            # Proprietary_ID
            $self->_get_SUSHI_Type_Value( $title_row->{Item_ID}, "Proprietary" ) || "",

            # ISBN
            grep ( /ISBN/, @{$specific_fields} )
            ? ( $self->_get_SUSHI_Type_Value( $title_row->{Item_ID}, "ISBN" ) || "" )
            : (),

            # Print_ISSN
            $self->_get_SUSHI_Type_Value( $title_row->{Item_ID}, "Print_ISSN" ) || "",

            # Online_ISSN
            $self->_get_SUSHI_Type_Value( $title_row->{Item_ID}, "Online_ISSN" ) || "",

            # URI - FIXME: What goes in URI?
            "",

            # YOP
            grep ( /YOP/, @{$specific_fields} ) ? ( $title_row->{YOP} || "" ) : (),

            # Access_Type
            grep ( /Access_Type/, @{$specific_fields} ) ? ( $title_row->{Access_Type} || "" ) : (),

            # Metric_Type
            $metric_type,

            # Report_Period_Total
            $total_usage,

            # Monthly usage entries
            @{$monthly_usages}
        ]
    );
}

=head3 _COUNTER_titles_report_column_headings

Return titles report column headings

=cut

sub _COUNTER_titles_report_column_headings {
    my ($self) = @_;

    my $header          = $self->{sushi}->{header};
    my @month_headings  = $self->_get_usage_months( $header, 1 );
    my $specific_fields = $self->get_report_type_specific_fields( $header->{Report_ID} );

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
        "IR_A1" => [
            'Authors',            'Publication_Date', 'Article_Version',  'Print_ISSN', 'Online_ISSN', 'Parent_Title',
            'Parent_Authors',     'Parent_Article_Version', 'Parent_DOI', 'Parent_Proprietary_ID', 'Parent_Print_ISSN',
            'Parent_Online_ISSN', 'Parent_URI',             'Access_Type'
        ],
    );

    return $report_type_map{$report_type};

}

1;
