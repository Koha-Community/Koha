#!/usr/bin/perl
# Copyright 2013 BibLibre
#
# This file is part of Koha
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use CGI;

use JSON;

use C4::Auth;
use C4::Output;
use C4::Items;
use C4::Biblio;
use C4::Koha;

use Koha::Item::Search::Field qw(GetItemSearchFields);
use Koha::ItemTypes;
use Koha::Libraries;

my $cgi = new CGI;
my %params = $cgi->Vars;

my $format = $cgi->param('format');
my ($template_name, $content_type);
if (defined $format and $format eq 'json') {
    $template_name = 'catalogue/itemsearch_json.tt';
    $content_type = 'json';

    # Map DataTables parameters with 'regular' parameters
    $cgi->param('rows', $cgi->param('iDisplayLength'));
    $cgi->param('page', ($cgi->param('iDisplayStart') / $cgi->param('iDisplayLength')) + 1);
    my @columns = split /,/, $cgi->multi_param('sColumns');
    $cgi->param('sortby', $columns[ $cgi->param('iSortCol_0') ]);
    $cgi->param('sortorder', $cgi->param('sSortDir_0'));

    my @f = $cgi->multi_param('f');
    my @q = $cgi->multi_param('q');
    push @q, '' if @q == 0;
    my @op = $cgi->multi_param('op');
    my @c = $cgi->multi_param('c');
    foreach my $i (0 .. ($cgi->param('iColumns') - 1)) {
        my $sSearch = $cgi->param("sSearch_$i");
        if (defined $sSearch and $sSearch ne '') {
            my @words = split /\s+/, $sSearch;
            foreach my $word (@words) {
                push @f, $columns[$i];
                push @q, "%$word%";
                push @op, 'like';
                push @c, 'and';
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
} else {
    $format = 'html';
    $template_name = 'catalogue/itemsearch.tt';
    $content_type = 'html';
}

my ($template, $borrowernumber, $cookie) = get_template_and_user({
    template_name => $template_name,
    query => $cgi,
    type => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { catalogue => 1 },
});

my $notforloan_avcode = GetAuthValCode('items.notforloan');
my $notforloan_values = GetAuthorisedValues($notforloan_avcode);

my $location_avcode = GetAuthValCode('items.location');
my $location_values = GetAuthorisedValues($location_avcode);

if (scalar keys %params > 0) {
    # Parameters given, it's a search

    my $filter = {
        conjunction => 'AND',
        filters => [],
    };

    foreach my $p (qw(homebranch location itype ccode issues datelastborrowed notforloan)) {
        if (my @q = $cgi->multi_param($p)) {
            if ($q[0] ne '') {
                my $f = {
                    field => $p,
                    query => \@q,
                };
                if (my $op = $cgi->param($p . '_op')) {
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
            if ($i == 0) {
                if (C4::Context->preference("marcflavour") ne "UNIMARC" && $field eq 'publicationyear') {
                    $field = 'copyrightdate';
                }
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
    foreach my $p (qw(damaged itemlost)) {
        my $v = $cgi->param($p) // '';
        my $f = {
            field => $p,
            query => 0,
        };
        if ($v eq 'yes') {
            $f->{operator} = '!=';
            push @{ $filter->{filters} }, $f;
        } elsif ($v eq 'no') {
            $f->{operator} = '=';
            push @{ $filter->{filters} }, $f;
        }
    }

    if (my $itemcallnumber_from = $cgi->param('itemcallnumber_from')) {
        push @{ $filter->{filters} }, {
            field => 'itemcallnumber',
            query => $itemcallnumber_from,
            operator => '>=',
        };
    }
    if (my $itemcallnumber_to = $cgi->param('itemcallnumber_to')) {
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
    if ($results) {
        # Get notforloan labels
        my $notforloan_map = {};
        foreach my $nfl_value (@$notforloan_values) {
            $notforloan_map->{$nfl_value->{authorised_value}} = $nfl_value->{lib};
        }

        # Get location labels
        my $location_map = {};
        foreach my $loc_value (@$location_values) {
            $location_map->{$loc_value->{authorised_value}} = $loc_value->{lib};
        }

        foreach my $item (@$results) {
            $item->{biblio} = GetBiblio($item->{biblionumber});
            ($item->{biblioitem}) = GetBiblioItemByBiblioNumber($item->{biblionumber});
            $item->{status} = $notforloan_map->{$item->{notforloan}};
            if (defined $item->{location}) {
                $item->{location} = $location_map->{$item->{location}};
            }
        }
    }

    $template->param(
        filter => $filter,
        search_params => $search_params,
        results => $results,
        total_rows => $total_rows,
        search_done => 1,
    );

    if ($format eq 'html') {
        # Build pagination bar
        my $url = '/cgi-bin/koha/catalogue/itemsearch.pl';
        my @params;
        foreach my $p (keys %params) {
            my @v = $cgi->multi_param($p);
            push @params, map { "$p=" . $_ } @v;
        }
        $url .= '?' . join ('&', @params);
        my $nb_pages = 1 + int($total_rows / $search_params->{rows});
        my $current_page = $search_params->{page};
        my $pagination_bar = pagination_bar($url, $nb_pages, $current_page, 'page');

        $template->param(pagination_bar => $pagination_bar);
    }
}

if ($format eq 'html') {
    # Retrieve data required for the form.

    my @branches = map { value => $_->branchcode, label => $_->branchname }, Koha::Libraries->search( {}, { order_by => 'branchname' } );
    my @locations;
    foreach my $location (@$location_values) {
        push @locations, {
            value => $location->{authorised_value},
            label => $location->{lib} // $location->{authorised_value},
        };
    }
    my @itemtypes;
    foreach my $itemtype ( Koha::ItemTypes->search ) {
        push @itemtypes, {
            value => $itemtype->itemtype,
            label => $itemtype->translated_description,
        };
    }
    my $ccode_avcode = GetAuthValCode('items.ccode') || 'CCODE';
    my $ccodes = GetAuthorisedValues($ccode_avcode);
    my @ccodes;
    foreach my $ccode (@$ccodes) {
        push @ccodes, {
            value => $ccode->{authorised_value},
            label => $ccode->{lib},
        };
    }

    my @notforloans;
    foreach my $value (@$notforloan_values) {
        push @notforloans, {
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
        locations => \@locations,
        itemtypes => \@itemtypes,
        ccodes => \@ccodes,
        notforloans => \@notforloans,
        items_search_fields => \@items_search_fields,
        authorised_values_json => to_json($authorised_values),
    );
}

if ($format eq 'csv') {
    print $cgi->header({
        type => 'text/csv',
        attachment => 'items.csv',
    });

    for my $line ( split '\n', $template->output ) {
        print "$line\n" unless $line =~ m|^\s*$|;
    }
} else {
    output_with_http_headers $cgi, $cookie, $template->output, $content_type;
}
