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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


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

=item newshelf

    if this parameter exists, then we create a new shelf

=back

=cut

use strict;
#use warnings; FIXME - Bug 2505
use C4::Biblio;
use CGI;
use C4::Output;
use C4::VirtualShelves qw/:DEFAULT GetRecentShelves/;
use C4::Circulation;
use C4::Auth;

# splits incoming biblionumber(s) to array and adds each to shelf.
sub AddBibliosToShelf {
    my ($shelfnumber,@biblionumber)=@_;

    # multiple bibs might come in as '/' delimited string (from where, i don't see), or as array.
    # (Note : they come in as '/' when added from the cart)
    if (scalar(@biblionumber) == 1) {
        @biblionumber = (split /\//,$biblionumber[0]);
    }
    for my $bib (@biblionumber){
        AddToShelf($bib, $shelfnumber);
    }
}

my $query           = new CGI;

# If set, then single item case.
my $biblionumber    = $query->param('biblionumber');

# If set, then multiple item case.
my @biblionumber   = $query->param('biblionumber');
my $biblionumbers   = $query->param('biblionumbers');

my $shelfnumber     = $query->param('shelfnumber');
my $newvirtualshelf = $query->param('newvirtualshelf');
my $newshelf        = $query->param('newshelf');
my $category        = $query->param('category');
my $sortfield	    = $query->param('sortfield');
my $confirmed       = $query->param('confirmed') || 0;


my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "virtualshelves/addbybiblionumber.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
    }
);

my @biblionumbers;
if ($biblionumbers) {
    @biblionumbers = split '/', $biblionumbers;
} else {
    @biblionumbers = (@biblionumber);
}
if (scalar(@biblionumber) == 1) {
        @biblionumber = (split /\//,$biblionumber[0]);
}

$shelfnumber = AddShelf( $newvirtualshelf, $loggedinuser, $category, $sortfield ) if $newvirtualshelf;
if ( $shelfnumber || ( $shelfnumber == -1 ) ) {    # the shelf already exist.

    if ($confirmed == 1) {
	AddBibliosToShelf($shelfnumber,@biblionumber);
	print
    "Content-Type: text/html\n\n<html><body onload=\"window.opener.location.reload(true);window.close()\"></body></html>";
	exit;
    } else {
	my ( $singleshelf, $singleshelfname, $singlecategory ) = GetShelf( $query->param('shelfnumber') );
	my @biblios;
        for my $bib (@biblionumber) {
	    my $data = GetBiblioData( $bib );
            push(@biblios,
                        { biblionumber => $bib,
                          title        => $data->{'title'},
                          author       => $data->{'author'},
                        } );
        }

       	$template->param
        (
         biblionumber => \@biblionumber,
         biblios      => \@biblios,
         multiple     => (scalar(@biblionumber) > 1),
         singleshelf  => 1,
         shelfname    => $singleshelfname,
         shelfnumber  => $singleshelf,
         total        => scalar(@biblionumber),
         confirm      => 1,
        );
    }
}
else {    # this shelf doesn't already exist.
    my $limit = 10;
    my ($shelflist);
    my @shelvesloop;
    my %shelvesloop;

    #grab each type of shelf, open (type 3) should not be limited by user.
    foreach my $shelftype (1,2,3) {
	    my ($shelflist) = GetRecentShelves($shelftype, $limit, $shelftype == 3 ? undef : $loggedinuser);
	    for my $shelf (@{ $shelflist }) {
		    push(@shelvesloop, $shelf->{shelfnumber});
		    $shelvesloop{$shelf->{shelfnumber}} = $shelf->{shelfname};
	    }
    }

    if( @shelvesloop ){
        my $CGIvirtualshelves = CGI::scrolling_list
          (
           -name     => 'shelfnumber',
           -values   => \@shelvesloop,
           -labels   => \%shelvesloop,
           -size     => 1,
           -tabindex => '',
           -multiple => 0
          );
        $template->param
          (
           CGIvirtualshelves => $CGIvirtualshelves,
          );
    }
   	my @biblios;
        for my $bib (@biblionumber) {
	    my $data = GetBiblioData( $bib );
            push(@biblios,
                        { biblionumber => $bib,
                          title        => $data->{'title'},
                          author       => $data->{'author'},
                        } );
        }
    $template->param(
           newshelf     => $newshelf,
	   biblios=>\@biblios,
           multiple     => (scalar(@biblionumber) > 1),
           total        => scalar(@biblionumber),
    );

    unless (@biblionumbers) {
        my ( $bibliocount, @biblios ) = GetBiblio($biblionumber);
    
        $template->param
          (
           biblionumber      => $biblionumber,
           title             => $biblios[0]->{'title'},
           author            => $biblios[0]->{'author'},
          );
    } else {
        my @biblioloop = ();
        foreach my $biblionumber (@biblionumbers) {
            my ( $bibliocount, @biblios ) = GetBiblio($biblionumber);
            my %biblioiter = (
                              title=>$biblios[0]->{'title'},
                              author=>$biblios[0]->{'author'}
                             );
            push @biblioloop, \%biblioiter;
        }
        $template->param
          (
           biblioloop => \@biblioloop,
           biblionumbers => $biblionumbers
          );
    }
    
}
output_html_with_http_headers $query, $cookie, $template->output;
