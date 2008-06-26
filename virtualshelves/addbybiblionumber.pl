#!/usr/bin/perl

#script to provide virtual shelf management
#
#
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


=head1 NAME

    addbybiblionumber.pl

=head1 DESCRIPTION

    This script allow to add a virtual in a virtual shelf from a biblionumber.

=head1 CGI PARAMETERS

=over 4

=item biblionumber

    The biblionumber

=item shelfnumber

    the shelfnumber where to add the virtual.

=item newvirtualshelf

    if this parameter exists, then it must be equals to the name of the shelf
    to add.

=item category

    if this script has to add a shelf, it add one with this category.

=back

=cut

use strict;
use C4::Biblio;
use CGI;
use C4::Output;
use C4::VirtualShelves;
use C4::Circulation;
use C4::Auth;

#use it only to debug !
use CGI::Carp qw/fatalsToBrowser/;
use warnings;

my $query           = new CGI;
my $biblionumber    = $query->param('biblionumber');
my $shelfnumber     = $query->param('shelfnumber');
my $newvirtualshelf = $query->param('newvirtualshelf');
my $category        = $query->param('category');
my $sortfield		= $query->param('sortfield');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "virtualshelves/addbybiblionumber.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
    }
);

$shelfnumber = AddShelf( $newvirtualshelf, $loggedinuser, $category, $sortfield )
  if $newvirtualshelf;
if ( $shelfnumber || ( $shelfnumber == -1 ) ) {    # the shelf already exist.
    AddToShelfFromBiblio( $biblionumber, $shelfnumber );
    print
"Content-Type: text/html\n\n<html><body onload=\"window.close()\"></body></html>";
    exit;
}
else {    # this shelf doesn't already exist.
    my ( $bibliocount, @biblios ) = GetBiblio($biblionumber);

	my $limit = 10;
	my ($shelflist) = GetRecentShelves(1, $limit, $loggedinuser);
    my @shelvesloop;
    my %shelvesloop;
    for my $shelf ( @{${@$shelflist}[0]} ) {
        push( @shelvesloop, $shelf->{shelfnumber} );
		$shelvesloop{$shelf->{shelfnumber}} = $shelf->{shelfname};
	}
	# then open shelves...
	my ($shelflist) = GetRecentShelves(3, $limit, undef);
    for my $shelf ( @{${@$shelflist}[0]} ) {
        push( @shelvesloop, $shelf->{shelfnumber} );
		$shelvesloop{$shelf->{shelfnumber}} = $shelf->{shelfname};
	}
	if(@shelvesloop gt 0){
    my $CGIvirtualshelves = CGI::scrolling_list(
        -name     => 'shelfnumber',
        -values   => \@shelvesloop,
        -labels   => \%shelvesloop,
        -size     => 1,
        -tabindex => '',
        -multiple => 0
    );
    $template->param(
	        CGIvirtualshelves => $CGIvirtualshelves,
    );
	}

    $template->param(
        biblionumber      => $biblionumber,
        title             => $biblios[0]->{'title'},
        author            => $biblios[0]->{'author'},
    );

    output_html_with_http_headers $query, $cookie, $template->output;
}
