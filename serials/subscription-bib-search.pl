#!/usr/bin/perl
# WARNING: 4-character tab stops here

# Copyright 2000-2002 Katipo Communications
# Parts Copyright 2010 Biblibre
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

=head1 NAME

subscription-bib-search.pl

=head1 DESCRIPTION

this script search among all existing subscriptions.

=head1 PARAMETERS

=over 4

=item op
op use to know the operation to do on this template.
 * do_search : to search the subscription.

Note that if op = do_search there are some others params specific to the search :
    marclist,and_or,excluding,operator,value

=item startfrom
to multipage gestion.


=back

=cut

use strict;
use warnings;

use CGI;
use C4::Koha;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Search;
use C4::Biblio;
use C4::Debug;

my $input = new CGI;
my $op = $input->param('op') || q{};
my $dbh = C4::Context->dbh;

my $startfrom = $input->param('startfrom');
$startfrom = 0 unless $startfrom;
my ( $template, $loggedinuser, $cookie );
my $resultsperpage;

my $itype_or_itemtype =
  ( C4::Context->preference("item-level_itypes") ) ? 'itype' : 'itemtype';

my $query = $input->param('q');

# don't run the search if no search term !
if ( $op eq "do_search" && $query ) {

    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "serials/result.tt",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1, serials => '*' },
            debug           => 1,
        }
    );

    # add the limits if applicable
    my $itemtypelimit = $input->param('itemtypelimit');
    my $ccodelimit    = $input->param('ccodelimit');
    my $op = C4::Context->preference('UseQueryParser') ? '&&' : 'and';
    $query .= " $op $itype_or_itemtype:$itemtypelimit" if $itemtypelimit;
    $query .= " $op ccode:$ccodelimit" if $ccodelimit;
    $debug && warn $query;
    $resultsperpage = $input->param('resultsperpage');
    $resultsperpage = 20 if ( !defined $resultsperpage );

    my ( $error, $marcrecords, $total_hits ) =
      SimpleSearch( $query, $startfrom * $resultsperpage, $resultsperpage );
    my $total = 0;
    if ( defined $marcrecords ) {
        $total = scalar @{$marcrecords};
    }

    if ( defined $error ) {
        $template->param( query_error => $error );
        warn "error: " . $error;
        output_html_with_http_headers $input, $cookie, $template->output;
        exit;
    }
    my @results;

    for ( my $i = 0 ; $i < $total ; $i++ ) {
        my %resultsloop;
        my $marcrecord = C4::Search::new_record_from_zebra( 'biblioserver', $marcrecords->[$i] );
        my $biblio = TransformMarcToKoha( C4::Context->dbh, $marcrecord, '' );

        #build the hash for the template.
        $resultsloop{highlight}       = ( $i % 2 ) ? (1) : (0);
        $resultsloop{title}           = $biblio->{'title'};
        $resultsloop{subtitle}        = $biblio->{'subtitle'};
        $resultsloop{biblionumber}    = $biblio->{'biblionumber'};
        $resultsloop{author}          = $biblio->{'author'};
        $resultsloop{publishercode}   = $biblio->{'publishercode'};
        $resultsloop{publicationyear} = $biblio->{'publicationyear'};
        $resultsloop{issn}            = $biblio->{'issn'};

        push @results, \%resultsloop;
    }

    # multi page display gestion
    my $displaynext = 0;
    my $displayprev = $startfrom;
    if ( ( $total_hits - ( ( $startfrom + 1 ) * ($resultsperpage) ) ) > 0 ) {
        $displaynext = 1;
    }

    my @numbers = ();

    if ( $total_hits > $resultsperpage ) {
        for ( my $i = 1 ; $i < $total / $resultsperpage + 1 ; $i++ ) {
            if ( $i < 16 ) {
                my $highlight = 0;
                ( $startfrom == ( $i - 1 ) ) && ( $highlight = 1 );
                push @numbers,
                  {
                    number     => $i,
                    highlight  => $highlight,
                    searchdata => \@results,
                    startfrom  => ( $i - 1 )
                  };
            }
        }
    }

    my $from = 0;
    $from = $startfrom * $resultsperpage + 1 if ( $total_hits > 0 );
    my $to;

    if ( $total_hits < ( ( $startfrom + 1 ) * $resultsperpage ) ) {
        $to = $total;
    }
    else {
        $to = ( ( $startfrom + 1 ) * $resultsperpage );
    }
    $template->param(
        query          => $query,
        resultsloop    => \@results,
        startfrom      => $startfrom,
        displaynext    => $displaynext,
        displayprev    => $displayprev,
        resultsperpage => $resultsperpage,
        startfromnext  => $startfrom + 1,
        startfromprev  => $startfrom - 1,
        total          => $total_hits,
        from           => $from,
        to             => $to,
        numbers        => \@numbers,
    );
}    # end of if ($op eq "do_search" & $query)
else {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "serials/subscription-bib-search.tt",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1, serials => '*' },
            debug           => 1,
        }
    );

    # load the itemtypes
    my $itemtypes = GetItemTypes();
    my @itemtypesloop;
    foreach my $thisitemtype (
        sort {
            $itemtypes->{$a}->{'description'}
              cmp $itemtypes->{$b}->{'description'}
        } keys %$itemtypes
      )
    {
        my %row = (
            code        => $thisitemtype,
            description => $itemtypes->{$thisitemtype}->{'description'},
        );
        push @itemtypesloop, \%row;
    }

    # load Collection Codes
    my $authvalues = GetAuthorisedValues('CCODE');
    my @ccodesloop;
    for my $thisauthvalue ( sort { $a->{'lib'} cmp $b->{'lib'} } @$authvalues )
    {
        my %row = (
            code        => $thisauthvalue->{'authorised_value'},
            description => $thisauthvalue->{'lib'},
        );
        push @ccodesloop, \%row;
    }

    $template->param(
        itemtypeloop => \@itemtypesloop,
        ccodeloop    => \@ccodesloop,
        no_query     => $op eq "do_search" ? 1 : 0,
    );
}

# Print the page
output_html_with_http_headers $input, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
