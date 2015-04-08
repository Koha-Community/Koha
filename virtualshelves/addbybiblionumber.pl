#!/usr/bin/perl

#script to provide virtual shelf management
#
#
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
use warnings;

use CGI;
use C4::Biblio;
use C4::Output;
use C4::VirtualShelves qw/:DEFAULT GetAllShelves/;
use C4::Auth;


our $query           = new CGI;
our @biblionumber    = HandleBiblioPars();
our $shelfnumber     = $query->param('shelfnumber');
our $newvirtualshelf = $query->param('newvirtualshelf');
our $newshelf        = $query->param('newshelf');
our $category        = $query->param('category');
our $sortfield	    = $query->param('sortfield');
my $confirmed       = $query->param('confirmed') || 0;
our $authorized      = 1;
our $errcode	    = 0;

our ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "virtualshelves/addbybiblionumber.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
    }
);

if( $newvirtualshelf) {
    HandleNewVirtualShelf();
    exit if $authorized;
    ShowTemplate(); #error message
}
elsif($shelfnumber && $confirmed) {
    HandleShelfNumber();
    exit if $authorized;
    ShowTemplate(); #error message
}
elsif($shelfnumber) { #still needs confirmation
    HandleSelectedShelf();
    LoadBib() if $authorized;
    ShowTemplate();
}
else {
    HandleSelect();
    LoadBib();
    ShowTemplate();
}
#end

sub HandleBiblioPars {
    my @bib= $query->param('biblionumber');
    if(@bib==0 && $query->param('biblionumbers')) {
        my $str= $query->param('biblionumbers');
        @bib= split '/', $str;
    }
    elsif(@bib==1 && $bib[0]=~/\//) {
        @bib= split '/', $bib[0];
    }
    return @bib;
}

sub AddBibliosToShelf {
    my ($shelfnumber, @biblionumber)=@_;
    for my $bib (@biblionumber){
        AddToShelf($bib, $shelfnumber, $loggedinuser);
    }
}

sub HandleNewVirtualShelf {
    $shelfnumber = AddShelf( {
        shelfname => $newvirtualshelf,
        sortfield => $sortfield,
        category => $category }, $loggedinuser);
    if($shelfnumber == -1) {
        $authorized=0;
        $errcode=1; #add failed
        return;
    }
    AddBibliosToShelf($shelfnumber, @biblionumber);
    #Reload the page where you came from
    print $query->header;
    print "<html><meta http-equiv=\"refresh\" content=\"0\" /><body onload=\"window.opener.location.reload(true);self.close();\"></body></html>";
}

sub HandleShelfNumber {
    if($authorized= ShelfPossibleAction($loggedinuser, $shelfnumber, 'add')) {
    AddBibliosToShelf($shelfnumber, @biblionumber);
    #Close this page and return
    print $query->header;
    print "<html><meta http-equiv=\"refresh\" content=\"0\" /><body onload=\"self.close();\"></body></html>";
    }
    else {
    $errcode=2; #no perm
    }
}

sub HandleSelectedShelf {
    if($authorized= ShelfPossibleAction( $loggedinuser, $shelfnumber, 'add')){
        #confirm adding to specific shelf
        my ($singleshelf, $singleshelfname)= GetShelf($shelfnumber);
        $template->param(
        singleshelf               => 1,
        shelfnumber               => $singleshelf,
        shelfname                 => $singleshelfname,
        );
    }
    else {
    $errcode=2; #no perm
    }
}

sub HandleSelect {
    my $privateshelves = GetAllShelves(1,$loggedinuser,1);
    my $publicshelves = GetAllShelves(2,$loggedinuser,1);
    $template->param(
    privatevirtualshelves => $privateshelves,
    publicvirtualshelves  => $publicshelves,
    );
}

sub LoadBib {
    my @biblios;
    for my $bib (@biblionumber) {
        my $data = GetBiblioData($bib);
    push(@biblios,
        { biblionumber => $bib,
          title        => $data->{'title'},
          author       => $data->{'author'},
    } );
    }
    $template->param(
        multiple => (scalar(@biblios) > 1),
    total    => scalar @biblios,
    biblios  => \@biblios,
    );
}

sub ShowTemplate {
    $template->param (
    newshelf => $newshelf||0,
    authorized	=> $authorized,
    errcode		=> $errcode,
    );
    output_html_with_http_headers $query, $cookie, $template->output;
}
