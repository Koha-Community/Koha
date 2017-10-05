#!/usr/bin/perl

# Copyright Liblime 2007
# Copyright Biblibre 2009
#
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


=head1 itemslost

This script displays lost items.

=cut

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::Items;

use Koha::AuthorisedValues;
use Koha::CsvProfiles;
use Koha::DateUtils;

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "reports/itemslost.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { reports => '*' },
        debug           => 1,
    }
);

my $params = $query->Vars;
my $get_items = $params->{'get_items'};
my $op = $query->param('op') || '';

if ( $op eq 'export' ) {
    my @itemnumbers = $query->multi_param('itemnumber');
    my $csv_profile_id = $query->param('csv_profile_id');
    my @rows;
    if ($csv_profile_id) {
        # FIXME This following code has the same logic as GetBasketAsCSV
        # We should refactor all the CSV export code
        # Note: For MARC it is already done in Koha::Exporter::Record but not for SQL CSV profiles type
        my $csv_profile = Koha::CsvProfiles->find( $csv_profile_id );
        die "There is no valid csv profile given" unless $csv_profile;

        my $csv = Text::CSV_XS->new({'quote_char'=>'"','escape_char'=>'"','sep_char'=>$csv_profile->csv_separator,'binary'=>1});
        my $csv_profile_content = $csv_profile->content;
        my ( @headers, @fields );
        while ( $csv_profile_content =~ /
            ([^=\|]+) # header
            =?
            ([^\|]*) # fieldname (table.row or row)
            \|? /gxms
        ) {
            my $header = $1;
            my $field = ($2 eq '') ? $1 : $2;

            $header =~ s/^\s+|\s+$//g; # Trim whitespaces
            push @headers, $header;

            $field =~ s/[^\.]*\.{1}//; # Remove the table name if exists.
            $field =~ s/^\s+|\s+$//g; # Trim whitespaces
            push @fields, $field;
        }
        my $items = Koha::Items->search({ itemnumber => { -in => \@itemnumbers } });
        while ( my $item = $items->next ) {
            my @row;
            my $all_fields = $item->unblessed;
            $all_fields = { %$all_fields, %{$item->biblio->unblessed}, %{$item->biblioitem->unblessed} };
            for my $field (@fields) {
                push @row, $all_fields->{$field};
            }
            push @rows, \@row;
        }
        my $content = join( $csv_profile->csv_separator, @headers ) . "\n";
        for my $row ( @rows ) {
            $csv->combine(@$row);
            my $string = $csv->string;
            $content .= $string . "\n";
        }
        print $query->header(
            -type       => 'text/csv',
            -attachment => 'lost_items.csv',
        );
        print $content;
        exit;
    }
} elsif ( $get_items ) {
    my $branchfilter     = $params->{'branchfilter'}     || undef;
    my $barcodefilter    = $params->{'barcodefilter'}    || undef;
    my $itemtypesfilter  = $params->{'itemtypesfilter'}  || undef;
    my $loststatusfilter = $params->{'loststatusfilter'} || undef;
    my $notforloanfilter = $params->{'notforloanfilter'} || undef;

    my $params = {
        ( $branchfilter ? ( homebranch => $branchfilter ) : () ),
        (
            $loststatusfilter
            ? ( itemlost => $loststatusfilter )
            : ( itemlost => { '!=' => 0 } )
        ),
        (
            $notforloanfilter
            ? ( notforloan => $notforloanfilter )
            : ()
        ),
        ( $barcodefilter ? ( barcode => { like => "%$barcodefilter%" } ) : () ),
    };

    my $attributes;
    if ($itemtypesfilter) {
        if ( C4::Context->preference('item-level_itypes') ) {
            $params->{itype} = $itemtypesfilter;
        }
        else {
            # We want a join on biblioitems
            $attributes = { join => 'biblioitem' };
            $params->{'biblioitem.itemtype'} = $itemtypesfilter;
        }
    }

    my $items = Koha::Items->search( $params, $attributes );

    $template->param(
        items     => $items,
        get_items => $get_items,
    );
}

# getting all itemtypes
my $itemtypes = Koha::ItemTypes->search_with_localization;

my $csv_profiles = Koha::CsvProfiles->search({ type => 'sql', used_for => 'export_lost_items' });

$template->param(
    itemtypes => $itemtypes,
    csv_profiles => $csv_profiles,
);

# writing the template
output_html_with_http_headers $query, $cookie, $template->output;
