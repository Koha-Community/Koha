package Koha::ERM::EUsage::COUNTER::5_1;

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

Koha::ERM::EUsage::COUNTER::5 - Koha COUNTER 5.1 Object class

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
https://cop5.projectcounter.org/en/5.1/04-reports/03-title-reports.html

=cut

sub _COUNTER_report_header {
    my ($self) = @_;

    my $header = $self->{sushi}->{header};

    my $metric_types       = $self->_get_SUSHI_Name_Value( $header->{Report_Filters}, "Metric_Type" );
    my @metric_types_array = split( /\|/, $metric_types );
    $metric_types = join( "; ", @metric_types_array ) if @metric_types_array;

    my $begin_date = $self->_get_SUSHI_Name_Value( $header->{Report_Filters}, "Begin_Date" );
    my $end_date   = $self->_get_SUSHI_Name_Value( $header->{Report_Filters}, "End_Date" );

    return (
        [ Report_Name      => $header->{Report_Name}                                              || "" ],
        [ Report_ID        => $header->{Report_ID}                                                || "" ],
        [ Release          => $header->{Release}                                                  || "" ],
        [ Institution_Name => $header->{Institution_Name}                                         || "" ],
        [ Institution_ID   => $self->get_mapped_SUSHI_values( 'Type', $header->{Institution_ID} ) || "" ],
        [ Metric_Types     => $metric_types                                                       || "" ],
        [ Report_Filters   => $self->get_mapped_SUSHI_values( 'Name', $header->{Report_Filters} ) || "" ],

        #TODO: Report_Attributes may need parsing, test this with a SUSHI response that provides it
        [ Report_Attributes => $header->{Report_Attributes} || "" ],
        [
            Exceptions => join(
                "; ", map( $_->{Code} . ": " . $_->{Message} . " (" . $_->{Data} . ")", @{ $header->{Exceptions} } )
                )
                || ""
        ],
        [ Reporting_Period => "Begin_Date=" . $begin_date . "; End_Date=" . $end_date ],
        [ Created          => $header->{Created}         || "" ],
        [ Created_By       => $header->{Created_By}      || "" ],
        [ Registry_Record  => $header->{Registry_Record} || "" ],
        [""]    #empty 14th line (COUNTER 5.1)
    );
}

=head3 get_counter51_value

    Given a SUSHI response, get the value for the given key in the correct format for the COUNTER report
    https://counter5.cambridge.org/r51/sushi-docs/

=cut

sub get_counter51_value {
    my ( $self, $item, $key ) = @_;
    my $counter_51_value = $item->{$key};
    if ( ref($counter_51_value) eq 'ARRAY' ) {
        return join( "; ", @$counter_51_value );
    } else {
        return $counter_51_value;
    }
}

=head3 get_mapped_SUSHI_values

    Given a SUSHI response, get the value for the given key in the correct format for the COUNTER report
    https://counter5.cambridge.org/r51/sushi-docs/

    It will return a string of the form "Name:Value;Name:Value;..."
    If the value is an array with a single element, just the value will be returned.
    If the value is an array with multiple elements, they will be joined with "|"

=cut

sub get_mapped_SUSHI_values {
    my ( $self, $key, $sushi_type_value ) = @_;

    return join(
        "; ",
        map {
            $_ . ":"
                . (
                ref $sushi_type_value->{$_} eq 'ARRAY'
                    && scalar( @{ $sushi_type_value->{$_} } ) == 1 ? $sushi_type_value->{$_}[0]
                : ( ref $sushi_type_value->{$_} eq 'ARRAY' && scalar( @{ $sushi_type_value->{$_} } ) > 1 )
                ? join( "|", @{ $sushi_type_value->{$_} } )
                : $sushi_type_value->{$_}
                )
        } keys %{$sushi_type_value}
    );
}

=head3 _get_SUSHI_Name_Value

Returns "Value" of a given "Name"

=cut

sub _get_SUSHI_Name_Value {
    my ( $self, $item, $name ) = @_;

    return $self->get_counter51_value( $item, $name );
}

=head3 _get_SUSHI_Type_Value

Returns "Value" of a given "Type"

=cut

sub _get_SUSHI_Type_Value {
    my ( $self, $item, $type ) = @_;

    return $self->get_counter51_value( $item, $type );
}

=head3 _get_COUNTER_row_usages

Returns the total and monthly usages for a row

=cut

sub _get_COUNTER_row_usages {
    my ( $self, $row, $metric_type, $access_type ) = @_;

    my @usage_months = $self->_get_usage_months( $self->{sushi}->{header} );

    my @usage_months_fields = ();
    my $count_total         = 0;

    foreach my $usage_month (@usage_months) {
        my $month_is_empty = 1;

        my $usage_to_add;
        if ($access_type) {
            my @access_type_performances =
                grep { $_->{Access_Type} eq $access_type } @{ $row->{Attribute_Performance} };
            $usage_to_add = $access_type_performances[0]->{Performance}->{$metric_type}->{$usage_month};
        } else {
            $usage_to_add = $row->{Attribute_Performance}->[0]->{Performance}->{$metric_type}->{$usage_month};
        }
        if ( defined $usage_to_add ) {
            $count_total += $usage_to_add;
            $month_is_empty = 0;
            push( @usage_months_fields, $usage_to_add );
        }

        if ($month_is_empty) {
            push( @usage_months_fields, 0 );
        }
    }

    return ( $count_total, @usage_months_fields );
}

=head3 get_SUSHI_metric_types

    Given a SUSHI report row, return a sorted list of all the metric types

=cut

sub get_SUSHI_metric_types {
    my ( $self, $report_row ) = @_;

    my @metric_types = ();
    @metric_types = keys %{ $report_row->{Attribute_Performance}->[0]->{Performance} };
    @metric_types = sort @metric_types;
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

        my $specific_fields = $self->get_report_type_specific_fields( $header->{Report_ID} );
        my $use_access_type = grep ( /Access_Type/, @{$specific_fields} ) ? 1 : 0;
        my $use_yop         = grep ( /YOP/,         @{$specific_fields} ) ? 1 : 0;
        my $use_data_type   = grep ( /Data_Type/,   @{$specific_fields} ) ? 1 : 0;

        if ($use_data_type) {
            my %data_types = map { $_->{Data_Type} => 1 } @{ $report_row->{Attribute_Performance} };
            my @data_types = sort keys %data_types;

            foreach my $data_type (@data_types) {

                if ($use_yop) {
                    my %yops = map  { $_->{YOP} => 1 } @{ $report_row->{Attribute_Performance} };
                    my @yops = sort { $b <=> $a } keys %yops;
                    foreach my $yop (@yops) {

                        if ($use_access_type) {
                            my @access_types = map { $_->{"Access_Type"} } @{ $report_row->{Attribute_Performance} };
                            foreach my $access_type (@access_types) {

                                # Add one report row for each metric_type we're working with
                                foreach my $metric_type (@metric_types) {
                                    push(
                                        @report_body,
                                        $self->_COUNTER_report_row(
                                            $report_row, $metric_type, $access_type, $yop,
                                            $data_type
                                        )
                                    );
                                }
                            }
                        } else {

                            # Add one report row for each metric_type we're working with
                            foreach my $metric_type (@metric_types) {
                                push(
                                    @report_body,
                                    $self->_COUNTER_report_row( $report_row, $metric_type, undef, $yop, $data_type )
                                );
                            }
                        }
                    }
                } else {

                    # Add one report row for each metric_type we're working with
                    foreach my $metric_type (@metric_types) {
                        push(
                            @report_body,
                            $self->_COUNTER_report_row( $report_row, $metric_type, undef, undef, $data_type )
                        );
                    }
                }
            }
        } elsif ($use_yop) {
            my %yops = map  { $_->{YOP} => 1 } @{ $report_row->{Attribute_Performance} };
            my @yops = sort { $b <=> $a } keys %yops;
            foreach my $yop (@yops) {

                if ($use_access_type) {
                    my @access_types = map { $_->{"Access_Type"} } @{ $report_row->{Attribute_Performance} };
                    foreach my $access_type (@access_types) {

                        # Add one report row for each metric_type we're working with
                        foreach my $metric_type (@metric_types) {
                            push(
                                @report_body,
                                $self->_COUNTER_report_row( $report_row, $metric_type, $access_type, $yop )
                            );
                        }
                    }
                } else {

                    # Add one report row for each metric_type we're working with
                    foreach my $metric_type (@metric_types) {
                        push( @report_body, $self->_COUNTER_report_row( $report_row, $metric_type, undef, $yop ) );
                    }
                }
            }

        } elsif ($use_access_type) {
            my @access_types = map { $_->{"Access_Type"} } @{ $report_row->{Attribute_Performance} };
            foreach my $access_type (@access_types) {

                # Add one report row for each metric_type we're working with
                foreach my $metric_type (@metric_types) {
                    push( @report_body, $self->_COUNTER_report_row( $report_row, $metric_type, $access_type ) );
                }
            }
        } else {
            foreach my $metric_type (@metric_types) {
                push( @report_body, $self->_COUNTER_report_row( $report_row, $metric_type ) );
            }
        }

    }

    return @report_body;
}

=head3 _COUNTER_title_report_row

Return a COUNTER title for the COUNTER titles report body
https://cop5.countermetrics.org/en/5.1.0.1/04-reports/03-title-reports.html#column-headings-elements

=cut

sub _COUNTER_title_report_row {
    my ( $self, $title_row, $metric_type, $total_usage, $monthly_usages, $access_type, $yop, $data_type ) = @_;

    my $header             = $self->{sushi}->{header};
    my $specific_fields    = $self->get_report_type_specific_fields( $header->{Report_ID} );
    my $access_type_to_use = $access_type ? $access_type : ( $title_row->{Access_Type} || "" );
    my $yop_to_use         = $yop         ? $yop         : ( $title_row->{YOP}         || "" );
    my $data_type_to_use   = $data_type   ? $data_type   : ( $title_row->{Data_Type}   || "" );

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

            # Data_Type
            grep ( /Data_Type/, @{$specific_fields} ) ? $data_type_to_use : (),

            # YOP
            grep ( /YOP/, @{$specific_fields} ) ? $yop_to_use : (),

            # Access_Type
            grep ( /Access_Type/, @{$specific_fields} ) ? $access_type_to_use : (),

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
            grep ( /Data_Type/, @{$specific_fields} ) ? ("Data_Type") : (),

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
        "TR_B1" => [ 'YOP', 'Data_Type', 'ISBN' ],
        "TR_B2" => [ 'YOP', 'Data_Type', 'ISBN' ],
        "TR_B3" => [ 'YOP', 'Data_Type', 'Access_Type', 'ISBN' ],
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
