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
use CGI;
use C4::Auth;
use C4::Catalogue;
use C4::Biblio;
use C4::Search;
use C4::Output;
use C4::Interface::CGI::Output;
use HTML::Template;

my $input      = new CGI;
my $isbn       = $input->param('isbn');
my $title      = $input->param('title');
my $offset     = $input->param('offset');
my $num        = $input->param('num');
my $showoffset = $offset + 1;
my $total;
my $count;
my @results;
my $marc_p = C4::Context->boolean_preference("marc");

if ( !$isbn && !$title ) {
    print $input->redirect('addbooks.pl');
}
else {
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "acqui.simple/isbnsearch.tmpl",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1 },
            debug           => 1,
        }
    );

    # fill with books in ACTIVE DB (biblio)
    if ( !$offset ) {
        $offset     = 0;
        $showoffset = 1;
    }
    if ( !$num ) { $num = 10 }
    ( $count, @results ) = isbnsearch( $isbn, $title );

    if ( $count < ( $offset + $num ) ) {
        $total = $count;
    }
    else {
        $total = $offset + $num;
    }    # else

    my @loop_data = ();
    my $toggle;
    for ( my $i = $offset ; $i < $total ; $i++ ) {
        if ( $i % 2 ) {
            $toggle = "#ffffcc";
        }
        else {
            $toggle = "white";
        }
        my %row_data;    # get a fresh hash for the row data
        $row_data{toggle}        = $toggle;
        $row_data{biblionumber}  = $results[$i]->{'biblionumber'};
        $row_data{title}         = $results[$i]->{'title'};
        $row_data{author}        = $results[$i]->{'author'};
        $row_data{copyrightdate} = $results[$i]->{'copyrightdate'};
        $row_data{NOTMARC}       = !$marc_p;	
        push ( @loop_data, \%row_data );
    }
    $template->param( startfrom => $offset + 1 );
    ( $offset + $num <= $count )
      ? ( $template->param( endat => $offset + $num ) )
      : ( $template->param( endat => $count ) );
    $template->param( numrecords => $count );
    my $nextstartfrom = ( $offset + $num < $count ) ? ( $offset + $num ) : (-1);
    my $prevstartfrom = ( $offset - $num >= 0 ) ? ( $offset - $num ) : (-1);
    $template->param( nextstartfrom => $nextstartfrom );
    my $displaynext = 1;
    my $displayprev = 0;
    ( $nextstartfrom == -1 ) ? ( $displaynext = 0 ) : ( $displaynext = 1 );
    ( $prevstartfrom == -1 ) ? ( $displayprev = 0 ) : ( $displayprev = 1 );
    $template->param( displaynext => $displaynext );
    $template->param( displayprev => $displayprev );
    my @numbers = ();
    my $term;
    my $value;

    if ($isbn) {
        $term  = "isbn";
        $value = $isbn;
    }
    else {
        $term  = "title";
        $value = $title;
    }
    if ( $count > 10 ) {
        for ( my $i = 1 ; $i < $count / 10 + 1 ; $i++ ) {
            if ( $i < 16 ) {
                my $highlight = 0;
                ( $offset == ( $i - 1 ) * 10 ) && ( $highlight = 1 );
                push @numbers,
                  {
                    number    => $i,
                    highlight => $highlight,
                    term      => $term,
                    value     => $value,
                    startfrom => ( $i - 1 ) * 10
                };
            }
        }
    }

    # fill with books in breeding farm
    ( $count, @results ) = breedingsearch( $title, $isbn );
    my @breeding_loop = ();
    for ( my $i = 0 ; $i <= $#results ; $i++ ) {
        my %row_data;
        if ( $i % 2 ) {
            $toggle = "#ffffcc";
        }
        else {
            $toggle = "white";
        }
        $row_data{toggle} = $toggle;
        $row_data{id}     = $results[$i]->{'id'};
        $row_data{isbn}   = $results[$i]->{'isbn'};
        $row_data{file}   = $results[$i]->{'file'};
        $row_data{title}  = $results[$i]->{'title'};
        $row_data{author} = $results[$i]->{'author'};
        $row_data{NOTMARC}= !$marc_p;	
        push ( @breeding_loop, \%row_data );
    }


    $template->param(
        isbn          => $isbn,
        title         => $title,
        showoffset    => $showoffset,
        total         => $total,
        offset        => $offset,
        loop          => \@loop_data,
        breeding_loop => \@breeding_loop,
        numbers       => \@numbers,
        term          => $term,
        value         => $value,
        NOTMARC       => !$marc_p
    );

    print $input->header(
        -type   => guesstype( $template->output ),
        -cookie => $cookie
      ),
      $template->output;
}    # else
