#!/usr/bin/perl

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
require Exporter;
use CGI;
use C4::Auth;

use C4::Context;
use C4::Auth;
use C4::Output;
use C4::AuthoritiesMarc;
use C4::Acquisition;
use C4::Koha;    # XXX subfield_is_koha_internal_p
use C4::Biblio;

my $query        = new CGI;
my $op           = $query->param('op');
my $authtypecode = $query->param('authtypecode');
my $dbh          = C4::Context->dbh;

my $authid = $query->param('authid');
my ( $template, $loggedinuser, $cookie );

my $authtypes = getauthtypes;
my @authtypesloop;
foreach my $thisauthtype ( sort { $authtypes->{$a}{'authtypetext'} cmp $authtypes->{$b}{'authtypetext'} }
    keys %$authtypes )
{
    my $selected = 1 if $thisauthtype eq $authtypecode;
    my %row = (
        value        => $thisauthtype,
        selected     => $selected,
        authtypetext => $authtypes->{$thisauthtype}{'authtypetext'},
    );
    push @authtypesloop, \%row;
}

if ( $op eq "do_search" ) {
    my @marclist  = $query->param('marclist');
    my @and_or    = $query->param('and_or');
    my @excluding = $query->param('excluding');
    my @operator  = $query->param('operator');
    my $orderby   = $query->param('orderby');
    my @value     = $query->param('value');

    my $startfrom      = $query->param('startfrom')      || 1;
    my $resultsperpage = $query->param('resultsperpage') || 20;

    my ( $results, $total ) =
      SearchAuthorities( \@marclist, \@and_or, \@excluding, \@operator, \@value,
        ( $startfrom - 1 ) * $resultsperpage,
        $resultsperpage, $authtypecode, $orderby );
#     use Data::Dumper; warn Data::Dumper::Dumper(@$results);
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "authorities/searchresultlist.tmpl",
            query           => $query,
            type            => 'intranet',
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1 },
            debug           => 1,
        }
    );

    my @field_data = ();

    # we must get parameters once again. Because if there is a mainentry, it
    # has been replaced by something else during the search, thus the links
    # next/previous would not work anymore
    my @marclist_ini = $query->param('marclist');
    for ( my $i = 0 ; $i <= $#marclist ; $i++ ) {
        if ($value[$i]){   
          push @field_data, { term => "marclist",  val => $marclist_ini[$i] };
          push @field_data, { term => "and_or",    val => $and_or[$i] };
          push @field_data, { term => "excluding", val => $excluding[$i] };
          push @field_data, { term => "operator",  val => $operator[$i] };
          push @field_data, { term => "value",     val => $value[$i] };
        }    
    }

    # construction of the url of each page
    my $base_url =
        'authorities-home.pl?'
      . join( '&amp;', map { $_->{term} . '=' . $_->{val} } @field_data )
      . '&amp;'
      . join(
        '&amp;',
        map { $_->{term} . '=' . $_->{val} } (
            { term => 'resultsperpage', val => $resultsperpage },
            { term => 'type',           val => 'intranet' },
            { term => 'op',             val => 'do_search' },
            { term => 'authtypecode',   val => $authtypecode },
            { term => 'orderby',        val => $orderby },
        )
      );

    my $from = ( $startfrom - 1 ) * $resultsperpage + 1;
    my $to;

    if ( $total < $startfrom * $resultsperpage ) {
        $to = $total;
    }
    else {
        $to = $startfrom * $resultsperpage;
    }

    $template->param( result => $results ) if $results;

    $template->param(
        pagination_bar => pagination_bar(
            $base_url,  int( $total / $resultsperpage ) + 1,
            $startfrom, 'startfrom'
        ),
        total     => $total,
        from      => $from,
        to        => $to,
        isEDITORS => $authtypecode eq 'EDITORS',
    );

}
elsif ( $op eq "delete" ) {

    &DelAuthority( $authid, 1 );

    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "authorities/authorities-home.tmpl",
            query           => $query,
            type            => 'intranet',
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1 },
            debug           => 1,
        }
    );

    # 	$template->param("statements" => \@statements,
    # 						"nbstatements" => $nbstatements);
}
else {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "authorities/authorities-home.tmpl",
            query           => $query,
            type            => 'intranet',
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1 },
            debug           => 1,
        }
    );

}

$template->param(
    authtypesloop => \@authtypesloop,
);

# Print the page
output_html_with_http_headers $query, $cookie, $template->output;
