#!/usr/bin/perl
# WARNING: 4-character tab stops here

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;

use CGI;
use C4::Output;
use C4::Auth;
use C4::Context;
use C4::AuthoritiesMarc;
use C4::Acquisition;
use C4::Koha;    # XXX subfield_is_koha_internal_p

my $query        = new CGI;
my $op           = $query->param('op');
my $authtypecode = $query->param('authtypecode');
my $index        = $query->param('index');
my $tagid        = $query->param('tagid');
my $resultstring = $query->param('result');
my $dbh          = C4::Context->dbh;

my $startfrom = $query->param('startfrom');
$startfrom = 0 if ( !defined $startfrom );
my ( $template, $loggedinuser, $cookie );
my $resultsperpage;

my $authtypes = getauthtypes;
my @authtypesloop;
foreach my $thisauthtype ( keys %$authtypes ) {
    my $selected = 1 if $thisauthtype eq $authtypecode;
    my %row = (
        value        => $thisauthtype,
        selected     => $selected,
        authtypetext => $authtypes->{$thisauthtype}{'authtypetext'},
        index        => $index,
    );
    push @authtypesloop, \%row;
}

if ( $op eq "do_search" ) {
    my @marclist  = $query->param('marclist');
    my @and_or    = $query->param('and_or');
    my @excluding = $query->param('excluding');
    my @operator  = $query->param('operator');
    my @value     = $query->param('value');
    my $orderby   = $query->param('orderby');

    $resultsperpage = $query->param('resultsperpage');
    $resultsperpage = 20 if ( !defined $resultsperpage );

    my ( $results, $total ) =
      SearchAuthorities( \@marclist, \@and_or, \@excluding, \@operator, \@value,
        $startfrom * $resultsperpage,
        $resultsperpage, $authtypecode, $orderby);
    # multi page display gestion
    my $displaynext = 0;
    my $displayprev = $startfrom;
    if ( ( $total - ( ( $startfrom + 1 ) * ($resultsperpage) ) ) > 0 ) {
        $displaynext = 1;
    }

    my @field_data = ();

    my @marclist_ini =
      $query->param('marclist')
      ; # get marclist again, as the previous one has been modified by catalogsearch (mainentry replaced by field name
    for ( my $i = 0 ; $i <= $#marclist ; $i++ ) {
        push @field_data, { term => "marclist",  val => $marclist_ini[$i] };
        push @field_data, { term => "and_or",    val => $and_or[$i] };
        push @field_data, { term => "excluding", val => $excluding[$i] };
        push @field_data, { term => "operator",  val => $operator[$i] };
        push @field_data, { term => "value",     val => $value[$i] };
    }

    my @numbers = ();

    if ( $total > $resultsperpage ) {
        for ( my $i = 1 ; $i < $total / $resultsperpage + 1 ; $i++ ) {
            if ( $i < 16 ) {
                my $highlight = 0;
                ( $startfrom == ( $i - 1 ) ) && ( $highlight = 1 );
                push @numbers,
                  {
                    number     => $i,
                    highlight  => $highlight,
                    searchdata => \@field_data,
                    startfrom  => ( $i - 1 )
                  };
            }
        }
    }

    my $from = $startfrom * $resultsperpage + 1;
    my $to;

    if ( $total < ( ( $startfrom + 1 ) * $resultsperpage ) ) {
        $to = $total;
    }
    else {
        $to = ( ( $startfrom + 1 ) * $resultsperpage );
    }
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "authorities/searchresultlist-auth.tmpl",
            query           => $query,
            type            => 'intranet',
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1 },
        }
    );

    $template->param( result => $results ) if $results;
    $template->param(
        orderby      => $orderby,
        startfrom      => $startfrom,
    displaynext    => $displaynext,
    displayprev    => $displayprev,
    resultsperpage => $resultsperpage,
    startfromnext  => $startfrom + 1,
    startfromprev  => $startfrom - 1,
        searchdata     => \@field_data,
        total          => $total,
        from           => $from,
        to             => $to,
        numbers        => \@numbers,
        authtypecode   => $authtypecode,
        mainmainstring => $value[0],
        mainstring     => $value[1],
        anystring      => $value[2],
    );
} else {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "authorities/auth_finder.tmpl",
            query           => $query,
            type            => 'intranet',
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1 },
        }
    );

    $template->param(
        resultstring => $resultstring,
    );
}

$template->param(
    tagid         => $tagid,
    index         => $index,
    authtypesloop => \@authtypesloop,
    authtypecode  => $authtypecode,
);

# Print the page
output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
