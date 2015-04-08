#!/usr/bin/perl

# Copyright 2011 Athens County Public Libraries
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

use warnings;
use strict;
use CGI;

use C4::Auth qw(:DEFAULT check_cookie_auth);
use C4::Biblio;
use C4::Context;
use C4::Dates qw(format_date);
use C4::Items;
use C4::Koha;
use C4::Tags qw(get_tags remove_tag get_tag_rows);
use C4::Output;

my $needed_flags = { tools => 'moderate_tags'
};    # FIXME: replace when more specific permission is created.

my $query        = CGI->new;
my $op           = $query->param('op') || '';
my $biblionumber = $query->param('biblionumber');
my $tag          = $query->param('tag');
my $tag_id       = $query->param('tag_id');

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "tags/list.tt",
        query           => $query,
        type            => "intranet",
        debug           => 1,
        authnotrequired => 0,
        flagsrequired   => $needed_flags,
    }
);

if ( $op eq "del" ) {
    remove_tag($tag_id);
    print $query->redirect("/cgi-bin/koha/tags/list.pl?tag=$tag");
}
else {

    my $marcflavour = C4::Context->preference('marcflavour');
    my @results;

    if ($tag) {
        my $taglist = get_tag_rows( { term => $tag } );
        for ( @{$taglist} ) {
            my $dat    = &GetBiblioData( $_->{biblionumber} );
            my $record = &GetMarcBiblio( $_->{biblionumber} );
            $dat->{'subtitle'} =
              GetRecordValue( 'subtitle', $record,
                GetFrameworkCode( $_->{biblionumber} ) );
            my @items = GetItemsInfo( $_->{biblionumber} );
            $dat->{biblionumber} = $_->{biblionumber};
            $dat->{tag_id}       = $_->{tag_id};
            $dat->{items}        = \@items;
            $dat->{TagLoop}      = get_tags(
                {
                    biblionumber => $_->{biblionumber},
                    'sort'       => '-weight',
                    limit        => 10
                }
            );
            push( @results, $dat );
        }

        my $resultsarray = \@results;

        $template->param(
            tag    => $tag,
            titles => $resultsarray,
        );
    }
}

output_html_with_http_headers $query, $cookie, $template->output;
