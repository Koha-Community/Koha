#!/usr/bin/perl

#script to provide virtualshelf management
# WARNING: This file uses 4-character tabs!
#
# $Header$
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

use strict;
use warnings;

use CGI;
use C4::Biblio;
use C4::VirtualShelves qw/:DEFAULT GetAllShelves/;
use C4::Output;
use C4::Auth;

our $query        	= new CGI;
our @biblionumber 	= $query->param('biblionumber');
our $selectedshelf 	= $query->param('selectedshelf');
our $newshelf 		= $query->param('newshelf');
our $shelfnumber  	= $query->param('shelfnumber');
our $newvirtualshelf	= $query->param('newvirtualshelf');
our $category     	= $query->param('category');
our $authorized          = 1;
our $errcode		= 0;
our @biblios;

our ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-addbybiblionumber.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
    }
);

if( $newvirtualshelf) {
    HandleNewVirtualShelf();
    exit if $authorized;
    ShowTemplate(); #error message
}
elsif($shelfnumber) {
    HandleShelfNumber();
    exit if $authorized;
    ShowTemplate(); #error message
}
elsif($selectedshelf) {
    HandleSelectedShelf();
    LoadBib() if $authorized;
    ShowTemplate();
}
else {
    HandleSelect();
    LoadBib() if $authorized;
    ShowTemplate();
}
#end

sub AddBibliosToShelf {
    #splits incoming biblionumber(s) to array and adds each to shelf.
    my ($shelfnumber,@biblionumber)=@_;

    #multiple bibs might come in as '/' delimited string (from where, i don't see), or as array.
    if (scalar(@biblionumber) == 1) {
        @biblionumber = (split /\//,$biblionumber[0]);
    }
    for my $bib (@biblionumber) {
        AddToShelf($bib, $shelfnumber, $loggedinuser);
    }
}

sub HandleNewVirtualShelf {
    if($authorized= ShelfPossibleAction($loggedinuser, undef, $category==1? 'new_private': 'new_public')) {
    $shelfnumber = AddShelf( {
            shelfname => $newvirtualshelf,
            category => $category }, $loggedinuser);
    if($shelfnumber == -1) {
        $authorized=0;
        $errcode=1;
        return;
    }
    AddBibliosToShelf($shelfnumber, @biblionumber);
    #Reload the page where you came from
    print $query->header;
    print "<html><meta http-equiv=\"refresh\" content=\"0\" /><body onload=\"window.opener.location.reload(true);self.close();\"></body></html>";
    }
}

sub HandleShelfNumber {
    if($authorized= ShelfPossibleAction($loggedinuser, $shelfnumber, 'add')) {
    AddBibliosToShelf($shelfnumber,@biblionumber);
    #Close this page and return
    print $query->header;
    print "<html><meta http-equiv=\"refresh\" content=\"0\" /><body onload=\"self.close();\"></body></html>";
    }
}

sub HandleSelectedShelf {
    if($authorized= ShelfPossibleAction( $loggedinuser, $selectedshelf, 'add')){
        #adding to specific shelf
        my ($singleshelf, $singleshelfname)= GetShelf($query->param('selectedshelf'));
        $template->param(
        singleshelf               => 1,
        shelfnumber               => $singleshelf,
        shelfname                 => $singleshelfname,
        );
    }
}

sub HandleSelect {
    return unless $authorized= $loggedinuser>0;
    my $privateshelves = GetAllShelves(1,$loggedinuser,1);
    if(@{$privateshelves}){
        $template->param (
        privatevirtualshelves          => $privateshelves,
        existingshelves => 1
    );
    }
    my $publicshelves = GetAllShelves(2,$loggedinuser,1);
    if(@{$publicshelves}){
        $template->param (
        publicvirtualshelves          => $publicshelves,
        existingshelves => 1
    );
    }
}

sub LoadBib {
    #see comment in AddBibliosToShelf
    if (scalar(@biblionumber) == 1) {
        @biblionumber = (split /\//,$biblionumber[0]);
    }
    for my $bib (@biblionumber) {
        my $data = GetBiblioData( $bib );
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
    OpacAllowPublicListCreation => C4::Context->preference('OpacAllowPublicListCreation'),
    );
    output_html_with_http_headers $query, $cookie, $template->output;
}
