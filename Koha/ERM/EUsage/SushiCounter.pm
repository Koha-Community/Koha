package Koha::ERM::EUsage::SushiCounter;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Text::CSV_XS qw( csv );

use base qw(Koha::Object);

=head1 NAME

Koha::ERM::EUsage::SushiCounter - Koha SushiCounter Object class

=head1 API

=head2 Class Methods

=head3 new

    my $sushi_counter =
        Koha::ERM::EUsage::SushiCounter->new( { response => decode_json( $response->decoded_content ) } );

=cut

sub new {
    my ( $class, $params ) = @_;

    my $counter_release;
    if ( $params->{response}->{Report_Header}->{Release} eq "5" ) {
        require Koha::ERM::EUsage::COUNTER::5;
        $counter_release = Koha::ERM::EUsage::COUNTER::5->new;
    } elsif ( $params->{response}->{Report_Header}->{Release} eq "5.1" ) {
        require Koha::ERM::EUsage::COUNTER::5_1;
        $counter_release = Koha::ERM::EUsage::COUNTER::5_1->new;
    } else {
        Koha::Exceptions::ERM::EUsage::CounterFile::UnsupportedRelease->throw(
            { counter_release => $params->{response}->{Report_Header}->{Release} } );
    }

    $counter_release->{sushi} = {
        header => $params->{response}->{Report_Header},
        body   => $params->{response}->{Report_Items}
    };

    #TODO: Handle empty $self->{sushi}->{body} here!

    return $counter_release;
}

=head3 get_COUNTER_from_SUSHI

    $self->get_COUNTER_from_SUSHI;

Get the COUNTER file generated from the SUSHI response

=cut

sub get_COUNTER_from_SUSHI {
    my ($self) = @_;

    # Get ready to build COUNTER file
    my @report_header          = $self->_COUNTER_report_header;
    my @report_column_headings = $self->_COUNTER_report_column_headings;
    my @report_body            = $self->_COUNTER_report_body;

    return $self->_build_COUNTER_report_file( \@report_header, \@report_column_headings, \@report_body );
}

=head2 Internal methods

=head3 _build_COUNTER_report_file

Build the COUNTER file
https://cop5.projectcounter.org/en/5.0.2/03-specifications/02-formats-for-counter-reports.html#report-header

=cut

sub _build_COUNTER_report_file {
    my ( $self, $header, $column_headings, $body ) = @_;

    my @report = ( @{$header}, @{$column_headings}, @{$body} );

    #TODO: change this to tab instead of comma
    csv( in => \@report, out => \my $counter_file, encoding => "utf-8", formula => 'empty' );

    return $counter_file;

}

=head3 _COUNTER_item_report_row

Return a COUNTER item for the COUNTER items report body
https://cop5.projectcounter.org/en/5.0.2/04-reports/04-item-reports.html#column-headings-elements

=cut

sub _COUNTER_item_report_row {
    my ( $self, $item_row, $metric_type, $total_usage, $monthly_usages ) = @_;

    my $header          = $self->{sushi}->{header};
    my $specific_fields = $self->get_report_type_specific_fields( $header->{Report_ID} );

    return (
        [
            $item_row->{Item}                                                 || "",
            $item_row->{Publisher}                                            || "",
            $self->_get_SUSHI_Type_Value( $item_row->{Publisher_ID}, "ISNI" ) || "",
            $item_row->{Platform}                                             || "",

            # Authors
            grep ( /Authors/, @{$specific_fields} )
            ? ( $self->_get_SUSHI_Type_Value( $item_row->{Item_Contributors}, "Author" ) || "" )
            : (),

            # Publication_Date
            grep ( /Publication_Date/, @{$specific_fields} )
            ? ( $self->_get_SUSHI_Type_Value( $item_row->{Item_Dates}, "Publication_Date" ) || "" )
            : (),

            # Article_Version
            grep ( /Article_Version/, @{$specific_fields} )
            ? ( $self->_get_SUSHI_Type_Value( $item_row->{Item_Attributes}, "Article_Version" ) || "" )
            : (),
            $self->_get_SUSHI_Type_Value( $item_row->{Item_ID}, "DOI" ) || "",

            $self->_get_SUSHI_Type_Value( $item_row->{Item_ID}, "Proprietary" ) || "",

            # Print_ISSN
            grep ( /Print_ISSN/, @{$specific_fields} )
            ? ( $self->_get_SUSHI_Type_Value( $item_row->{Item_ID}, "Print_ISSN" ) || "" )
            : (),

            # Online_ISSN
            grep ( /Online_ISSN/, @{$specific_fields} )
            ? ( $self->_get_SUSHI_Type_Value( $item_row->{Item_ID}, "Online_ISSN" ) || "" )
            : (),
            "",    #FIXME: What goes in URI?

            # Parent_Title
            grep ( /Parent_Title/, @{$specific_fields} ) ? ( $item_row->{Item_Parent}->{Item_Name} || "" ) : (),

            # Parent_Authors
            grep ( /Parent_Authors/, @{$specific_fields} )
            ? ( $self->_get_SUSHI_Type_Value( $item_row->{Item_Parent}->{Item_Contributors}, "Author" ) || "" )
            : (),

            # Parent_Article_Version
            grep ( /Parent_Article_Version/, @{$specific_fields} )
            ? ( $self->_get_SUSHI_Type_Value( $item_row->{Item_Parent}->{Item_Attributes}, "Article_Version" ) || "" )
            : (),

            # Parent_DOI
            grep ( /Parent_DOI/, @{$specific_fields} )
            ? ( $self->_get_SUSHI_Type_Value( $item_row->{Item_Parent}->{Item_ID}, "DOI" )
                    || "" )
            : (),

            # Parent_Proprietary_ID
            grep ( /Parent_Proprietary_ID/, @{$specific_fields} )
            ? ( $self->_get_SUSHI_Type_Value( $item_row->{Item_Parent}->{Item_ID}, "Proprietary" )
                    || "" )
            : (),

            # Parent_Print_ISSN
            grep ( /Parent_Print_ISSN/, @{$specific_fields} )
            ? ( $self->_get_SUSHI_Type_Value( $item_row->{Item_Parent}->{Item_ID}, "Print_ISSN" )
                    || "" )
            : (),

            # Parent_Online_ISSN
            grep ( /Parent_Online_ISSN/, @{$specific_fields} )
            ? ( $self->_get_SUSHI_Type_Value( $item_row->{Item_Parent}->{Item_ID}, "Online_ISSN" )
                    || "" )
            : (),

            # Parent_URI
            grep ( /Parent_Online_ISSN/, @{$specific_fields} ) ? "" : (),

            # Access_Type
            grep ( /Access_Type/, @{$specific_fields} ) ? ( $item_row->{Access_Type} || "" ) : (),

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
    my ( $self, $database_row, $metric_type, $total_usage, $monthly_usages ) = @_;

    return (
        [
            $database_row->{Database}                                             || "",
            $database_row->{Publisher}                                            || "",
            $self->_get_SUSHI_Type_Value( $database_row->{Publisher_ID}, "ISNI" ) || "",
            $database_row->{Platform}                                             || "",
            $database_row->{Proprietary_ID}                                       || "",
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
    my ( $self, $platform_row, $metric_type, $total_usage, $monthly_usages ) = @_;

    return (
        [
            $platform_row->{Platform} || "", $metric_type,
            $total_usage,                    @{$monthly_usages}
        ]
    );
}

=head3 _COUNTER_report_row

Return a COUNTER row for the COUNTER report body

=cut

sub _COUNTER_report_row {
    my ( $self, $report_row, $metric_type, $access_type, $yop, $data_type ) = @_;

    my $header = $self->{sushi}->{header};

    my ( $total_usage, @monthly_usages ) = $self->_get_COUNTER_row_usages( $report_row, $metric_type, $access_type );

    if ( $header->{Report_ID} =~ /PR/i ) {
        return $self->_COUNTER_platform_report_row(
            $report_row,  $metric_type,
            $total_usage, \@monthly_usages
        );
    } elsif ( $header->{Report_ID} =~ /DR/i ) {
        return $self->_COUNTER_database_report_row( $report_row, $metric_type, $total_usage, \@monthly_usages );
    } elsif ( $header->{Report_ID} =~ /IR/i ) {

        #TODO: Send $access_type to _COUNTER_item_report_row like we're doing with _COUNTER_title_report_row
        return $self->_COUNTER_item_report_row( $report_row, $metric_type, $total_usage, \@monthly_usages );
    } elsif ( $header->{Report_ID} =~ /TR/i ) {
        return $self->_COUNTER_title_report_row(
            $report_row,  $metric_type, $total_usage, \@monthly_usages,
            $access_type, $yop,         $data_type
        );
    }
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
    } elsif ( $header->{Report_ID} =~ /DR/i ) {
        return $self->_COUNTER_databases_report_column_headings;
    } elsif ( $header->{Report_ID} =~ /IR/i ) {
        return $self->_COUNTER_items_report_column_headings;
    } elsif ( $header->{Report_ID} =~ /TR/i ) {
        return $self->_COUNTER_titles_report_column_headings;
    }

    return;
}

=head3 _COUNTER_items_report_column_headings

Return items report column headings

=cut

sub _COUNTER_items_report_column_headings {
    my ($self) = @_;

    my $header          = $self->{sushi}->{header};
    my @month_headings  = $self->_get_usage_months( $header, 1 );
    my $specific_fields = $self->get_report_type_specific_fields( $header->{Report_ID} );

    return (
        [
            "Item",
            "Publisher",
            "Publisher_ID",
            "Platform",
            grep ( /Authors/,          @{$specific_fields} ) ? ("Authors")          : (),
            grep ( /Publication_Date/, @{$specific_fields} ) ? ("Publication_Date") : (),
            grep ( /Article_Version/,  @{$specific_fields} ) ? ("Article_Version")  : (),
            "DOI",
            "Proprietary_ID",

            # "ISBN", #IR only
            grep ( /Print_ISSN/,  @{$specific_fields} ) ? ("Print_ISSN")  : (),
            grep ( /Online_ISSN/, @{$specific_fields} ) ? ("Online_ISSN") : (),
            "URI",
            grep ( /Parent_Title/,   @{$specific_fields} ) ? ("Parent_Title")   : (),
            grep ( /Parent_Authors/, @{$specific_fields} ) ? ("Parent_Authors") : (),

            # "Parent_Publication_Date", #IR only
            grep ( /Parent_Article_Version/, @{$specific_fields} ) ? ("Parent_Article_Version") : (),

            # "Parent_Data_Type", #IR only
            grep ( /Parent_DOI/,            @{$specific_fields} ) ? ("Parent_DOI")            : (),
            grep ( /Parent_Proprietary_ID/, @{$specific_fields} ) ? ("Parent_Proprietary_ID") : (),

            # "Parent_ISBN", #IR only
            grep ( /Parent_Print_ISSN/,  @{$specific_fields} ) ? ("Parent_Print_ISSN")  : (),
            grep ( /Parent_Online_ISSN/, @{$specific_fields} ) ? ("Parent_Online_ISSN") : (),
            grep ( /Parent_URI/,         @{$specific_fields} ) ? ("Parent_URI")         : (),

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
            grep ( /Access_Type/, @{$specific_fields} ) ? ("Access_Type") : (),

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

=head3 get_report_type_specific_fields_by_release

Returns the specific fields for a given report_type

=cut

sub get_report_type_specific_fields_by_release {
    my ( $self, $report_type, $counter_release ) = @_;

    if ( $counter_release eq "5" ) {
        require Koha::ERM::EUsage::COUNTER::5;
        return Koha::ERM::EUsage::COUNTER::5->get_report_type_specific_fields($report_type);
    } elsif ( $counter_release eq "5.1" ) {
        require Koha::ERM::EUsage::COUNTER::5_1;
        return Koha::ERM::EUsage::COUNTER::5_1->get_report_type_specific_fields($report_type);
    }
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

    my @begin_date  = $self->_get_SUSHI_Name_Value( $header->{Report_Filters}, 'Begin_Date' );
    my $begin_month = substr( $begin_date[0], 5, 2 );
    my $begin_year  = substr( $begin_date[0], 0, 4 );

    my @end_date  = $self->_get_SUSHI_Name_Value( $header->{Report_Filters}, 'End_Date' );
    my $end_month = substr( $end_date[0], 5, 2 );
    my $end_year  = substr( $end_date[0], 0, 4 );

    my @month_headings = ();
    while ( $begin_year <= $end_year && ( $begin_year != $end_year || $begin_month <= $end_month ) ) {
        push(
            @month_headings,
            $column_headings_formatting
            ? $months[ $begin_month - 1 ] . " " . $begin_year
            : $begin_year . "-" . $begin_month
        );
        $begin_month++;
        if ( $begin_month > 12 ) {
            $begin_month = 1;
            $begin_year++;
        }
        $begin_month = "0" . $begin_month if length($begin_month) == 1;
    }

    return @month_headings;
}

=head3 _type

=cut

sub _type {
    return 'ErmSushiCounter';
}

1;
