#!/usr/bin/perl
# WARNING: 4-character tab stops here

# Copyright 2000-2002 Katipo Communications
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

use strict;
use warnings;

use CGI;
use C4::Output;
use C4::Auth;
use C4::Context;
use C4::AuthoritiesMarc;
use C4::Acquisition;
use C4::Koha;

my $query        = new CGI;
my $op           = $query->param('op') || '';
my $authtypecode = $query->param('authtypecode') || '';
my $index        = $query->param('index') || '';
my $tagid        = $query->param('tagid') || '';
my $source       = $query->param('source') || '';
my $relationship = $query->param('relationship') || '';

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => ( $op eq 'do_search' )
        ? 'authorities/searchresultlist-auth.tt'
        : 'authorities/auth_finder.tt',
        query           => $query,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
    }
);

# Authority types loop
my $authtypes = C4::Koha::getauthtypes();
my @authtypesloop;
foreach my $thisauthtype ( keys %$authtypes ) {
    my %row = (
        value        => $thisauthtype,
        selected     => ( $thisauthtype eq $authtypecode ),
        authtypetext => $authtypes->{$thisauthtype}{'authtypetext'},
        index        => $index,
    );
    push @authtypesloop, \%row;
}

# If search form posted
if ( $op eq "do_search" ) {
    my @marclist  = $query->param('marclist');
    my @and_or    = $query->param('and_or');
    my @excluding = $query->param('excluding');
    my @operator  = $query->param('operator');
    my @value     = (
        $query->param('value_mainstr') || undef,
        $query->param('value_main')    || undef,
        $query->param('value_any')     || undef,
        $query->param('value_match')   || undef
    );
    my $orderby        = $query->param('orderby')        || '';
    my $startfrom      = $query->param('startfrom')      || 0;
    my $resultsperpage = $query->param('resultsperpage') || 20;

    my ( $results, $total ) =
      SearchAuthorities( \@marclist, \@and_or, \@excluding, \@operator, \@value,
        $startfrom * $resultsperpage,
        $resultsperpage, $authtypecode, $orderby );

    # multi page display gestion
    my $displaynext = 0;
    my $displayprev = $startfrom;
    if ( ( $total - ( ( $startfrom + 1 ) * ($resultsperpage) ) ) > 0 ) {
        $displaynext = 1;
    }

    my @field_data = ();

# get marclist again, as the previous one has been modified by catalogsearch (mainentry replaced by field name)
    my @marclist_ini = $query->param('marclist');
    for ( my $i = 0 ; $i <= $#marclist ; $i++ ) {
        push @field_data, { term => "marclist",  val => $marclist_ini[$i] };
        push @field_data, { term => "and_or",    val => $and_or[$i] };
        push @field_data, { term => "excluding", val => $excluding[$i] };
        push @field_data, { term => "operator",  val => $operator[$i] };
    }

    push @field_data,
      { term => "value_mainstr", val => $query->param('value_mainstr') || "" };
    push @field_data,
      { term => "value_main", val => $query->param('value_main') || "" };
    push @field_data,
      { term => "value_any", val => $query->param('value_any') || "" };
    push @field_data,
      { term => "value_match", val => $query->param('value_match') || "" };

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

    $template->param( result => $results ) if $results;
    $template->param(
        orderby          => $orderby,
        startfrom        => $startfrom,
        displaynext      => $displaynext,
        displayprev      => $displayprev,
        resultsperpage   => $resultsperpage,
        startfromnext    => $startfrom + 1,
        startfromprev    => $startfrom - 1,
        searchdata       => \@field_data,
        total            => $total,
        from             => $from,
        to               => $to,
        numbers          => \@numbers,
        operator_mainstr => ( @operator > 0 && $operator[0] )
        ? $operator[0]
        : '',
        operator_main  => ( @operator > 1 && $operator[1] ) ? $operator[1] : '',
        operator_any   => ( @operator > 2 && $operator[2] ) ? $operator[2] : '',
        operator_match => ( @operator > 3 && $operator[3] ) ? $operator[3] : '',
    );
}
else {

    # special case for UNIMARC field 210c builder
    my $resultstring = $query->param('result') || '';
    $template->param( resultstring => $resultstring, );
}

$template->param(
    op            => $op,
    value_mainstr => $query->param('value_mainstr') || '',
    value_main    => $query->param('value_main') || '',
    value_any     => $query->param('value_any') || '',
    value_match   => $query->param('value_match') || '',
    tagid         => $tagid,
    index         => $index,
    authtypesloop => \@authtypesloop,
    authtypecode  => $authtypecode,
    source        => $source,
    relationship  => $relationship,
);

# Print the page
output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
