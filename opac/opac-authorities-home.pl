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

use C4::Auth;

use C4::Context;
use C4::Auth;
use C4::Output;
use C4::AuthoritiesMarc;
use C4::Koha;    # XXX subfield_is_koha_internal_p
use C4::Search::History;

my $query        = new CGI;
my $op           = $query->param('op') || '';
my $authtypecode = $query->param('authtypecode') || '';
my $dbh          = C4::Context->dbh;

my $startfrom = $query->param('startfrom');
my $authid    = $query->param('authid');
$startfrom = 0 if ( !defined $startfrom );
my ( $template, $loggedinuser, $cookie );
my $resultsperpage;

my $authtypes     = getauthtypes();
my @authtypesloop = ();
foreach my $thisauthtype (
    sort {
        $authtypes->{$a}->{'authtypetext'}
          cmp $authtypes->{$b}->{'authtypetext'}
    }
    keys %{$authtypes}
  ) {
    push @authtypesloop,
      { value        => $thisauthtype,
        selected     => $thisauthtype eq $authtypecode,
        authtypetext => $authtypes->{$thisauthtype}->{'authtypetext'},
      };
}

if ( $op eq "do_search" ) {
    my @marclist = ($query->param('marclist'));
    my @and_or = ($query->param('and_or'));
    my @excluding = ($query->param('excluding'),);
    my @operator = ($query->param('operator'));
    my $orderby = $query->param('orderby');
    my @value = ($query->param('value') || "",);

    $resultsperpage = $query->param('resultsperpage');
    $resultsperpage = 20 if ( !defined $resultsperpage );
    my @tags;
    my ( $results, $total, @fields ) =
      SearchAuthorities( \@marclist, \@and_or, \@excluding, \@operator,
        \@value, $startfrom * $resultsperpage,
        $resultsperpage, $authtypecode, $orderby );
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-authoritiessearchresultlist.tt",
            query           => $query,
            type            => 'opac',
            authnotrequired => 1,
            debug           => 1,
        }
    );

    # multi page display gestion
    my $displaynext = 0;
    my $displayprev = $startfrom;
    $total ||= 0;
    if ( ( $total - ( ( $startfrom + 1 ) * ($resultsperpage) ) ) > 0 ) {
        $displaynext = 1;
    }

    my @field_data = (
        { term => "marclist",  val => $marclist[0] },
        { term => "and_or",    val => $and_or[0] },
        { term => "excluding", val => $excluding[0] },
        { term => "operator",  val => $operator[0] },
        { term => "value",     val => $value[0] },
    );

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
    unless (C4::Context->preference('OPACShowUnusedAuthorities')) {
        my @usedauths = grep { $_->{used} > 0 } @$results;
        $results = \@usedauths;
    }

    # Opac search history
    if (C4::Context->preference('EnableOpacSearchHistory')) {
        unless ( $startfrom ) {
            my $path_info = $query->url(-path_info=>1);
            my $query_cgi_history = $query->url(-query=>1);
            $query_cgi_history =~ s/^$path_info\?//;
            $query_cgi_history =~ s/;/&/g;

            unless ( $loggedinuser ) {
                my $new_search = C4::Search::History::add_to_session({
                        cgi => $query,
                        query_desc => $value[0],
                        query_cgi => $query_cgi_history,
                        total => $total,
                        type => "authority",
                });
            } else {
                # To the session (the user is logged in)
                C4::Search::History::add({
                    userid => $loggedinuser,
                    sessionid => $query->cookie("CGISESSID"),
                    query_desc => $value[0],
                    query_cgi => $query_cgi_history,
                    total => $total,
                    type => "authority",
                });
            }
        }
    }

    $template->param( result => $results ) if $results;
    $template->param( FIELDS => \@fields );
    $template->param( orderby => $orderby );
    $template->param(
        startfrom      => $startfrom,
        displaynext    => $displaynext,
        displayprev    => $displayprev,
        resultsperpage => $resultsperpage,
        startfromnext  => $startfrom + 1,
        startfromprev  => $startfrom - 1,
        searchdata     => \@field_data,
        countfuzzy     => !(C4::Context->preference('OPACShowUnusedAuthorities')),
        total          => $total,
        from           => $from,
        to             => $to,
        resultcount    => scalar @$results,
        numbers        => \@numbers,
        authtypecode   => $authtypecode,
        authtypetext   => $authtypes->{$authtypecode}{'authtypetext'},
        isEDITORS      => $authtypecode eq 'EDITORS',
    );

}
else {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-authorities-home.tt",
            query           => $query,
            type            => 'opac',
            authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
            debug           => 1,
        }
    );

}

$template->param( authtypesloop => \@authtypesloop );

# Print the page
output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
