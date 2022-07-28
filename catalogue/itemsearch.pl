#!/usr/bin/perl
# Copyright 2013 BibLibre
#
# This file is part of Koha
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
use CGI;

use JSON qw( to_json );

use C4::Auth qw( get_template_and_user );
use C4::Circulation qw( barcodedecode );
use C4::Output qw( output_with_http_headers output_html_with_http_headers );
use C4::Items qw( SearchItems );
use C4::Koha qw( GetAuthorisedValues );

use Koha::AuthorisedValues;
use Koha::Biblios;
use Koha::Item::Search::Field qw(GetItemSearchFields);
use Koha::ItemTypes;
use Koha::Libraries;

my $cgi = CGI->new;
my %params = $cgi->Vars;

my $format = $cgi->param('format');
my $template_name = 'catalogue/itemsearch.tt';

if (defined $format and $format eq 'json') {
    $template_name = 'catalogue/itemsearch_json.tt';

    # Map DataTables parameters with 'regular' parameters
    $cgi->param('rows', scalar $cgi->param('iDisplayLength'));
    $cgi->param('page', (scalar $cgi->param('iDisplayStart') / scalar $cgi->param('iDisplayLength')) + 1);
    my @columns = split /,/, scalar $cgi->param('sColumns');
    $cgi->param('sortby', $columns[ scalar $cgi->param('iSortCol_0') ]);
    $cgi->param('sortorder', scalar $cgi->param('sSortDir_0'));

    my @f = $cgi->multi_param('f');
    my @q = $cgi->multi_param('q');

    # If index indicates the value is a barcode, we need to preproccess it before searching
    for ( my $i = 0; $i < @q; $i++ ) {
        $q[$i] = barcodedecode($q[$i]) if $f[$i] eq 'barcode';
    }

    push @q, '' if @q == 0;
    my @op = $cgi->multi_param('op');
    my @c = $cgi->multi_param('c');
    my $iColumns = $cgi->param('iColumns');
    foreach my $i (0 .. ($iColumns - 1)) {
        my $sSearch = $cgi->param("sSearch_$i");
        if (defined $sSearch and $sSearch ne '') {
            my @words = split /\s+/, $sSearch;
            foreach my $word (@words) {
                push @f, $columns[$i];
                push @c, 'and';

                if ( grep { $_ eq $columns[$i] } qw( ccode homebranch holdingbranch location itype notforloan itemlost onloan ) ) {
                    push @q, "$word";
                    push @op, '=';
                } else {
                    push @q, "%$word%";
                    push @op, 'like';
                }
            }
        }
    }
    $cgi->param('f', @f);
    $cgi->param('q', @q);
    $cgi->param('op', @op);
    $cgi->param('c', @c);
} elsif (defined $format and $format eq 'csv') {
    $template_name = 'catalogue/itemsearch_csv.tt';

    # Retrieve all results
    $cgi->param('rows', 0);
} elsif (defined $format and $format eq 'barcodes') {
    # Retrieve all results
    $cgi->param('rows', 0);
} elsif (defined $format) {
    die "Unsupported format $format";
}

my ($template, $borrowernumber, $cookie) = get_template_and_user({
    template_name => $template_name,
    query => $cgi,
    type => 'intranet',
    flagsrequired   => { catalogue => 1 },
});

my $mss = Koha::MarcSubfieldStructures->search({ frameworkcode => '', kohafield => 'items.itemlost', authorised_value => [ -and => {'!=' => undef }, {'!=' => ''}] });
my $itemlost_values = $mss->count ? GetAuthorisedValues($mss->next->authorised_value) : [];

$mss = Koha::MarcSubfieldStructures->search({ frameworkcode => '', kohafield => 'items.withdrawn', authorised_value => [ -and => {'!=' => undef }, {'!=' => ''}] });
my $withdrawn_values = $mss->count ? GetAuthorisedValues($mss->next->authorised_value) : [];

if ( Koha::MarcSubfieldStructures->search( { frameworkcode => '', kohafield => 'items.new_status' } )->count ) {
    $template->param( has_new_status => 1 );
}

if ( defined $format ) {
    # Parameters given, it's a search

    my $filter = {
        conjunction => 'AND',
        filters => [],
    };

    foreach my $p (qw(homebranch holdingbranch location itype ccode issues datelastborrowed notforloan itemlost withdrawn)) {
        if (my @q = $cgi->multi_param($p)) {
            if ($q[0] ne '') {
                my $f = {
                    field => $p,
                    query => \@q,
                };
                if (my $op = scalar $cgi->param($p . '_op')) {
                    $f->{operator} = $op;
                }
                push @{ $filter->{filters} }, $f;
            }
        }
    }

    my @c = $cgi->multi_param('c');
    my @fields = $cgi->multi_param('f');
    my @q = $cgi->multi_param('q');
    my @op = $cgi->multi_param('op');

    my $f;
    for (my $i = 0; $i < @fields; $i++) {
        my $field = $fields[$i];
        my $q = shift @q;
        my $op = shift @op;
        if (defined $q and $q ne '') {
            if (C4::Context->preference("marcflavour") ne "UNIMARC" && $field eq 'publicationyear') {
                $field = 'copyrightdate';
            }

            if ($i == 0) {
                $f = {
                    field => $field,
                    query => $q,
                    operator => $op,
                };
            } else {
                my $c = shift @c;
                $f = {
                    conjunction => $c,
                    filters => [
                        $f, {
                            field => $field,
                            query => $q,
                            operator => $op,
                        }
                    ],
                };
            }
        }
    }
    push @{ $filter->{filters} }, $f;

    # Yes/No parameters
    foreach my $p (qw( damaged new_status )) {
        my $v = $cgi->param($p) // '';
        my $f = {
            field => $p,
            query => 0,
        };
        if ( $p eq 'new_status' ) {
            $f->{ifnull} = 0;
        }
        if ($v eq 'yes') {
            $f->{operator} = '!=';
            push @{ $filter->{filters} }, $f;
        } elsif ($v eq 'no') {
            $f->{operator} = '=';
            push @{ $filter->{filters} }, $f;
        }
    }

    # null/is not null parameters
    foreach my $p (qw( onloan )) {
        my $v = $cgi->param($p) // '';
        my $f = {
            field => $p,
            operator => "is",
        };
        if ( $v eq 'IS NOT NULL' ) {
            $f->{query} = "not null";
        } elsif ( $v eq 'IS NULL' ) {
            $f->{query} = "null";
        }
        push @{ $filter->{filters} }, $f unless ( $v eq "" );
    }

    if (my $itemcallnumber_from = scalar $cgi->param('itemcallnumber_from')) {
        push @{ $filter->{filters} }, {
            field => 'itemcallnumber',
            query => $itemcallnumber_from,
            operator => '>=',
        };
    }
    if (my $itemcallnumber_to = scalar $cgi->param('itemcallnumber_to')) {
        push @{ $filter->{filters} }, {
            field => 'itemcallnumber',
            query => $itemcallnumber_to,
            operator => '<=',
        };
    }

    my $sortby = $cgi->param('sortby') || 'itemnumber';
    if (C4::Context->preference("marcflavour") ne "UNIMARC" && $sortby eq 'publicationyear') {
        $sortby = 'copyrightdate';
    }
    my $search_params = {
        rows => scalar $cgi->param('rows') // 20,
        page => scalar $cgi->param('page') || 1,
        sortby => $sortby,
        sortorder => scalar $cgi->param('sortorder') || 'asc',
    };

    my ($results, $total_rows) = SearchItems($filter, $search_params);

    if ($format eq 'barcodes') {
        print $cgi->header({
            type => 'text/plain',
            attachment => 'barcodes.txt',
        });

        foreach my $item (@$results) {
            print $item->{barcode} . "\n";
        }
        exit;
    }

    if ($results) {
        foreach my $item (@$results) {
            my $biblio = Koha::Biblios->find( $item->{biblionumber} );
            $item->{biblio} = $biblio;
            $item->{biblioitem} = $biblio->biblioitem->unblessed;
            my $checkout = Koha::Checkouts->find({ itemnumber => $item->{itemnumber} });
            $item->{checkout} = $checkout;
        }
    }

    $template->param(
        filter => $filter,
        search_params => $search_params,
        results => $results,
        total_rows => $total_rows,
    );

    if ($format eq 'csv') {
        print $cgi->header({
            type => 'text/csv',
            attachment => 'items.csv',
        });

        for my $line ( split '\n', $template->output ) {
            print "$line\n" unless $line =~ m|^\s*$|;
        }
    } elsif ($format eq 'json') {
        $template->param(sEcho => scalar $cgi->param('sEcho'));
        output_with_http_headers $cgi, $cookie, $template->output, 'json';
    }

    exit;
}

# Display the search form

my @branches = map { value => $_->branchcode, label => $_->branchname }, Koha::Libraries->search( {}, { order_by => 'branchname' } )->as_list;
my @itemtypes = map { value => $_->itemtype, label => $_->translated_description }, Koha::ItemTypes->search_with_localization->as_list;

my @ccodes = Koha::AuthorisedValues->get_descriptions_by_koha_field({ kohafield => 'items.ccode' });
foreach my $ccode (@ccodes) {
    $ccode->{value} = $ccode->{authorised_value},
    $ccode->{label} = $ccode->{lib},
}

my @itemlosts;
foreach my $value (@$itemlost_values) {
    push @itemlosts, {
        value => $value->{authorised_value},
        label => $value->{lib},
    };
}

my @withdrawns;
foreach my $value (@$withdrawn_values) {
    push @withdrawns, {
        value => $value->{authorised_value},
        label => $value->{lib},
    };
}

my @items_search_fields = GetItemSearchFields();

my $authorised_values = {};
foreach my $field (@items_search_fields) {
    if (my $category = ($field->{authorised_values_category})) {
        $authorised_values->{$category} = GetAuthorisedValues($category);
    }
}

$template->param(
    branches => \@branches,
    itemtypes => \@itemtypes,
    ccodes => \@ccodes,
    itemlosts => \@itemlosts,
    withdrawns => \@withdrawns,
    items_search_fields => \@items_search_fields,
    authorised_values_json => to_json($authorised_values),
);

output_html_with_http_headers $cgi, $cookie, $template->output;
