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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use CGI;
use URI::Escape;
use C4::Auth;

use C4::Context;
use C4::Auth;
use C4::Output;
use C4::AuthoritiesMarc;
use C4::Acquisition;
use C4::Koha;    # XXX subfield_is_koha_internal_p
use C4::Biblio;

my $query = new CGI;
my $dbh   = C4::Context->dbh;
my $op           = $query->param('op')           || '';
my $authtypecode = $query->param('authtypecode') || '';
my $authid       = $query->param('authid')       || '';

my ( $template, $loggedinuser, $cookie );

my $authtypes = getauthtypes;
my @authtypesloop;
foreach my $thisauthtype (
    sort {
        $authtypes->{$a}{'authtypetext'} cmp $authtypes->{$b}{'authtypetext'}
    }
    keys %$authtypes
  )
{
    my %row = (
        value        => $thisauthtype,
        selected     => $thisauthtype eq $authtypecode,
        authtypetext => $authtypes->{$thisauthtype}{'authtypetext'},
    );
    push @authtypesloop, \%row;
}

if ( $op eq "delete" ) {
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
    &DelAuthority( $authid, 1 );

    if ( $query->param('operator') ) {
        # query contains search params so perform search
        $op = "do_search";
    }
    else {
        $op = '';
    }
}
if ( $op eq "do_search" ) {
    my $marclist  = $query->param('marclist')  || '';
    my $and_or    = $query->param('and_or')    || '';
    my $excluding = $query->param('excluding') || '';
    my $operator  = $query->param('operator')  || '';
    my $orderby   = $query->param('orderby')   || '';
    my $value     = $query->param('value')     || '';

    my $startfrom      = $query->param('startfrom')      || 1;
    my $resultsperpage = $query->param('resultsperpage') || 20;

    my ( $results, $total ) = SearchAuthorities(
        [$marclist],  [$and_or],
        [$excluding], [$operator],
        [$value], ( $startfrom - 1 ) * $resultsperpage,
        $resultsperpage, $authtypecode,
        $orderby
    );

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

    $template->param(
        marclist       => $marclist,
        and_or         => $and_or,
        excluding      => $excluding,
        operator       => $operator,
        orderby        => $orderby,
        value          => $value,
        authtypecode   => $authtypecode,
        startfrom      => $startfrom,
        resultsperpage => $resultsperpage,
    );

    # we must get parameters once again. Because if there is a mainentry, it
    # has been replaced by something else during the search, thus the links
    # next/previous would not work anymore

    # construction of the url of each page
    my $value_url = uri_escape($value);
    my $base_url = "authorities-home.pl?"
      ."marclist=$marclist"
      ."&amp;and_or=$and_or"
      ."&amp;excluding=$excluding"
      ."&amp;operator=$operator"
      ."&amp;value=$value_url"
      ."&amp;resultsperpage=$resultsperpage"
      ."&amp;type=intranet"
      ."&amp;op=do_search"
      ."&amp;authtypecode=$authtypecode"
      ."&amp;orderby=$orderby";

    my $from = ( $startfrom - 1 ) * $resultsperpage + 1;
    my $to;
    if ( !defined $total ) {
        $total = 0;
    }

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
if ( $op eq '' ) {
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
    op            => $op,
);

$template->{VARS}->{marcflavour} = C4::Context->preference("marcflavour");

# Print the page
output_html_with_http_headers $query, $cookie, $template->output;
