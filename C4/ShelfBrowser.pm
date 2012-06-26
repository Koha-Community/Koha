#!/usr/bin/perl

package C4::ShelfBrowser;

# Copyright 2010 Catalyst IT
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

use C4::Biblio;
use C4::Branch;
use C4::Context;
use C4::Koha;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

BEGIN {
    $VERSION = 3.07.00.049;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
	    &GetNearbyItems
    );
    @EXPORT_OK = qw(
    );
}

=head1 NAME

C4::ShelfBrowser - functions that deal with the shelf browser feature found in
the OPAC.

=head1 SYNOPSIS

  use C4::ShelfBrowser;

=head1 DESCRIPTION

This module provides functions to get items nearby to another item, for use
in the shelf browser function.

'Nearby' is controlled by a handful of system preferences that specify what
to take into account.

=head1 FUNCTIONS

=head2 GetNearbyItems($itemnumber, [$num_each_side])

  $nearby = GetNearbyItems($itemnumber, [$num_each_side]);

  @next = @{ $nearby->{next} };
  @prev = @{ $nearby->{prev} };

  foreach (@next) {
      # These won't format well like this, but here are the fields
  	  print $_->{title};
  	  print $_->{biblionumber};
  	  print $_->{itemnumber};
  	  print $_->{browser_normalized_upc};
  	  print $_->{browser_normalized_oclc};
  	  print $_->{browser_normalized_isbn};
  }

  # This is the information required to scroll the browser to the next left
  # or right set. Can be derived from next/prev, but it's here for convenience.
  print $nearby->{prev_itemnumber};
  print $nearby->{next_itemnumber};
  print $nearby->{prev_biblionumber};
  print $nearby->{next_biblionumber};

  # These will be undef if the values are not used to calculate the 
  # nearby items.
  print $nearby->{starting_homebranch}->{code};
  print $nearby->{starting_homebranch}->{description};
  print $nearby->{starting_location}->{code};
  print $nearby->{starting_location}->{description};
  print $nearby->{starting_ccode}->{code};
  print $nearby->{starting_ccode}->{description};

  print $nearby->{starting_itemnumber};
  
This finds the items that are nearby to the supplied item, and supplies
those previous and next, along with the other useful information for displaying
the shelf browser.

It automatically applies the following user preferences to work out how to
calculate things: C<ShelfBrowserUsesLocation>, C<ShelfBrowserUsesHomeBranch>, 
C<ShelfBrowserUsesCcode>.

The option C<$num_each_side> value determines how many items will be fetched
each side of the supplied item. Note that the item itself is the first entry
in the 'next' set, and counts towards this limit (this is to keep the
behaviour consistant with the code that this is a refactor of.) Default is
3.

This will throw an exception if something went wrong.

=cut

sub GetNearbyItems {
	my ($itemnumber, $num_each_side) = @_;
	$num_each_side ||= 3;

    my $dbh         = C4::Context->dbh;
    my $marcflavour = C4::Context->preference("marcflavour");
    my $branches = GetBranches();

    my $sth_get_item_details = $dbh->prepare("SELECT cn_sort,homebranch,location,ccode from items where itemnumber=?");
    $sth_get_item_details->execute($itemnumber);
    my $item_details_result = $sth_get_item_details->fetchrow_hashref();
    die "Unable to find item '$itemnumber' for shelf browser" if (!$sth_get_item_details);
    my $start_cn_sort = $item_details_result->{'cn_sort'};

    my ($start_homebranch, $start_location, $start_ccode);
    if (C4::Context->preference('ShelfBrowserUsesHomeBranch') && 
    	defined($item_details_result->{'homebranch'})) {
        $start_homebranch->{code} = $item_details_result->{'homebranch'};
        $start_homebranch->{description} = $branches->{$item_details_result->{'homebranch'}}{branchname};
    }
    if (C4::Context->preference('ShelfBrowserUsesLocation') && 
    	defined($item_details_result->{'location'})) {
        $start_location->{code} = $item_details_result->{'location'};
        $start_location->{description} = GetAuthorisedValueDesc('','',$item_details_result->{'location'},'','','LOC','opac');
    }
    if (C4::Context->preference('ShelfBrowserUsesCcode') && 
    	defined($item_details_result->{'ccode'})) {
        $start_ccode->{code} = $item_details_result->{'ccode'};
        $start_ccode->{description} = GetAuthorisedValueDesc('', '', $item_details_result->{'ccode'}, '', '', 'CCODE', 'opac');
    }

    # Build the query for previous and next items
    my $prev_query ='
        SELECT *
        FROM items
        WHERE
            ((cn_sort = ? AND itemnumber < ?) OR cn_sort < ?) ';
    my $next_query ='
        SELECT *
        FROM items
        WHERE
            ((cn_sort = ? AND itemnumber >= ?) OR cn_sort > ?) ';
    my @params;
    my $query_cond;
    push @params, ($start_cn_sort, $itemnumber, $start_cn_sort);
    if ($start_homebranch) {
    	$query_cond .= 'AND homebranch = ? ';
    	push @params, $start_homebranch->{code};
    }
    if ($start_location) {
    	$query_cond .= 'AND location = ? ';
    	push @params, $start_location->{code};
    }
    if ($start_ccode) {
    	$query_cond .= 'AND ccode = ? ';
    	push @params, $start_ccode->{code};
    }

    my $sth_prev_items = $dbh->prepare($prev_query . $query_cond . ' ORDER BY cn_sort DESC, itemnumber LIMIT ?');
    my $sth_next_items = $dbh->prepare($next_query . $query_cond . ' ORDER BY cn_sort, itemnumber LIMIT ?');
    push @params, $num_each_side;
    $sth_prev_items->execute(@params);
    $sth_next_items->execute(@params);
    
    # Now we have the query run, suck out the data like marrow
    my @prev_items = reverse GetShelfInfo($sth_prev_items, $marcflavour);
    my @next_items = GetShelfInfo($sth_next_items, $marcflavour);

    my (
        $next_itemnumber, $next_biblionumber,
        $prev_itemnumber, $prev_biblionumber
    );

    $next_itemnumber = $next_items[-1]->{itemnumber} if @next_items;
    $next_biblionumber = $next_items[-1]->{biblionumber} if @next_items;

    $prev_itemnumber = $prev_items[0]->{itemnumber} if @prev_items;
    $prev_biblionumber = $prev_items[0]->{biblionumber} if @prev_items;

    my %result = (
        next                => \@next_items,
        prev                => \@prev_items,
        next_itemnumber     => $next_itemnumber,
        next_biblionumber   => $next_biblionumber,
        prev_itemnumber     => $prev_itemnumber,
        prev_biblionumber   => $prev_biblionumber,   
        starting_itemnumber => $itemnumber,
    );
    $result{starting_homebranch} = $start_homebranch if $start_homebranch;
    $result{starting_location}   = $start_location   if $start_location;
    $result{starting_ccode}         = $start_ccode      if $start_ccode;
    return \%result;
}

# This runs through a statement handle and pulls out all the items in it, fills
# them up with additional info that shelves want, and returns those as a list.
# Not really intended to be exported.
sub GetShelfInfo {
    my ($sth, $marcflavour) = @_;

    my @items;
    while (my $this_item = $sth->fetchrow_hashref()) {
        my $this_biblio = GetBibData($this_item->{biblionumber});
        next if (!defined($this_biblio));
        $this_item->{'title'} = $this_biblio->{'title'};
        my $this_record = GetMarcBiblio($this_biblio->{'biblionumber'});
        $this_item->{'browser_normalized_upc'} = GetNormalizedUPC($this_record,$marcflavour);
        $this_item->{'browser_normalized_oclc'} = GetNormalizedOCLCNumber($this_record,$marcflavour);
        $this_item->{'browser_normalized_isbn'} = GetNormalizedISBN(undef,$this_record,$marcflavour);
        push @items, $this_item;
    }
    return @items;
}

# Fetches some basic biblio data needed by the shelf stuff
sub GetBibData {
	my ($bibnum) = @_;

    my $dbh         = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT biblionumber, title FROM biblio WHERE biblionumber=?");
    $sth->execute($bibnum);
    my $bib = $sth->fetchrow_hashref();
    return $bib;
}

1;
