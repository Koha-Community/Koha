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

use Modern::Perl;
use CGI qw ( -utf8 );

use C4::Auth   qw( get_template_and_user );
use C4::Biblio qw( GetBiblioData );
use C4::Context;
use C4::Tags   qw( get_tag_rows get_tags remove_tag );
use C4::Output qw( output_html_with_http_headers );

use Koha::Biblios;

my $needed_flags = { tools => 'moderate_tags' };    # FIXME: replace when more specific permission is created.

my $query        = CGI->new;
my $op           = $query->param('op') || '';
my $biblionumber = $query->param('biblionumber');
my $tag          = $query->param('tag');
my $tag_id       = $query->param('tag_id');

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "tags/list.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => $needed_flags,
    }
);

if ( $op eq "cud-del" ) {
    remove_tag($tag_id);
    print $query->redirect("/cgi-bin/koha/tags/list.pl?tag=$tag");
} else {

    my $marcflavour = C4::Context->preference('marcflavour');
    my @results;

    if ($tag) {
        my $taglist = get_tag_rows( { term => $tag } );
        for ( @{$taglist} ) {

            # FIXME We should use Koha::Biblio here
            my $dat   = &GetBiblioData( $_->{biblionumber} );
            my $items = Koha::Items->search_ordered( { 'me.biblionumber' => $dat->{biblionumber} } );
            $dat->{biblionumber} = $_->{biblionumber};
            $dat->{tag_id}       = $_->{tag_id};
            $dat->{items}        = $items;
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
