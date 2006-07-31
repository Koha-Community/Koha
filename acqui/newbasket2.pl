#!/usr/bin/perl

#origninally script to provide intranet (librarian) advanced search facility
#now script to do searching for acquisitions

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

newbasket2.pl

=head1 DESCRIPTION
this script allows to perform a new order from an existing record.

=head1 CGI PARAMETERS

=over 4

=item search
the title the librarian has typed to search an existing record.

=item type
To know if this script is called from intranet or from the opac.

=item d
the keyword the librarian has typed to search an existing record.

=item author
the author of the new record.

=item offset

=item num

=item booksellerid
the id of the bookseller this script has to add an order.

=item basketno
the basket number to know on which basket this script have to add a new order.

=item sub
FIXME : is this param still used ?

=back

=cut


use strict;
use C4::Search;
use CGI;
use C4::Output;
use C4::Bookseller;
use C4::Biblio;
use HTML::Template;
use C4::Auth;
use C4::Interface::CGI::Output;


#use Data::Dumper;

my $env;
my $input = new CGI;

#print $input->header;

#whether it is called from the opac of the intranet
my $type = $input->param('type');
if ( $type eq '' ) {
    $type = 'intra';
}

#print $input->dump;
my $blah;
my %search;

#build hash of users input
my $title = $input->param('search');
$search{'title'} = $title;
my $keyword = $input->param('d');
$search{'keyword'} = $keyword;
my $author = $input->param('author');
$search{'author'} = $author;

my @results;
my $offset = $input->param('offset');

#default value for offset
my $offset = 0 unless $offset;

my $num = $input->param('num');

#default value for num
my $num = 10 unless $num;

my $donation;
my $booksellerid = $input->param('booksellerid');
if ( $booksellerid == 72 ) {
    $donation = 'yes';
}
my $basketno = $input->param('basketno');
my $sub      = $input->param('sub');

#print $sub;
my @booksellers = GetBookSeller($booksellerid);
my $count = scalar @booksellers;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/newbasket2.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { order => 1 },
        debug           => 1,
    }
);

#my $template = gettemplate("acqui/newbasket2.tmpl");
#print startpage();
#print startmenu('acquisitions');
my $invalidsearch;

if ( $keyword ne '' ) {
    ( $count, @results ) =
      KeywordSearch( undef, 'intra', \%search, $num, $offset );
}
elsif ( $search{'front'} ne '' ) {
    ( $count, @results ) =
      FrontSearch( undef, 'intra', \%search, $num, $offset );
}
elsif ( $search{'author'} || $search{'title'} ) {
    ( $count, @results ) = CatSearch( undef, 'loose', \%search, $num, $offset );
}
else {
    $invalidsearch = 1;
}

my @loopsearch;

while ( my ( $key, $value ) = each %search ) {
    if ( $value ne '' ) {
        my %linesearch;
        $value =~ s/\\//g;
        $linesearch{key}   = $key;
        $linesearch{value} = $value;
        push( @loopsearch, \%linesearch );
    }
}

my $offset2 = $num + $offset;
my $dispnum = $offset + 1;
if ( $offset2 > $count ) {
    $offset2 = $count;
}

my $count2 = @results;
if ( $keyword ne '' && $offset > 0 ) {
    $count2 = $count - $offset;
    if ( $count2 > 10 ) {
        $count2 = 10;
    }
}
my $i      = 0;
my $colour = 0;

my @loopresult;

while ( $i < $count2 ) {
    my %lineres;
    my $toggle;

    my $result = $results[$i];
    $result->{'title'} =~ s/\`/\\\'/g;
    my $title2  = $result->{'title'};
    my $author2 = $result->{'author'};
    $author2 =~ s/ /%20/g;
    $title2  =~ s/ /%20/g;
    $title2  =~ s/\#/\&\#x23;/g;
    $title2  =~ s/\"/\&quot\;/g;

    my $itemcount;
    my $location      = '';
    my $location_only = '';
    my $word          = $result->{'author'};
    $word =~ s/([a-z]) +([a-z])/$1%20$2/ig;
    $word =~ s/  //g;
    $word =~ s/ /%20/g;
    $word =~ s/\,/\,%20/g;
    $word =~ s/\n//g;
    $lineres{word} = $word;
    $lineres{type} = $type;

    my ( $counts, $branchcounts ) =
      C4::Search::itemcount( $env, $result->{'biblionumber'}, $type );

    if ( $counts->{'nacount'} > 0 ) {
        $location .= "On Loan";
        if ( $counts->{'nacount'} > 1 ) {
            $location .= "=($counts->{'nacount'})";
        }
        $location .= " ";
        $lineres{'on-loan-p'} = 1;
    }
    foreach my $key ( keys %$branchcounts ) {
        if ( $branchcounts->{$key} > 0 ) {
            $location      .= $key;
            $location_only .= $key;

            if ( $branchcounts->{$key} > 1 ) {
                $location      .= "=$branchcounts->{$key}";
                $location_only .= "=$branchcounts->{$key}";
            }
            $location      .= " ";
            $location_only .= " ";
        }
    }
    if ( $counts->{'lostcount'} > 0 ) {
        $location .= "Lost";
        if ( $counts->{'lostcount'} > 1 ) {
            $location .= "=($counts->{'lostcount'})";
        }
        $location .= " ";
        $lineres{'lost-p'} = 1;
    }
    if ( $counts->{'mending'} > 0 ) {
        $location .= "Mending";
        if ( $counts->{'mending'} > 1 ) {
            $location .= "=($counts->{'mending'})";
        }
        $location .= " ";
        $lineres{'mending-p'} = 1;
    }
    if ( $counts->{'transit'} > 0 ) {
        $location .= "In Transit";
        if ( $counts->{'transit'} > 1 ) {
            $location .= "=($counts->{'transit'})";
        }
        $location .= " ";
        $lineres{'in-transit-p'} = 1;
    }
    if ( $colour eq 0 ) {
        $toggle = 1;
        $colour = 1;
    }
    else {
        $colour = 0;
        $toggle = 0;
    }
    $lineres{author2}         = $author2;
    $lineres{title2}          = $title2;
    $lineres{copyright}       = $result->{'copyrightdate'};
    $lineres{booksellerid}    = $booksellerid;
    $lineres{basketno}        = $basketno;
    $lineres{sub}             = $sub;
    $lineres{biblionumber}    = $result->{biblionumber};
    $lineres{title}           = $result->{title};
    $lineres{author}          = $result->{author};
    $lineres{toggle}          = $toggle;
    $lineres{itemcount}       = $counts->{'count'};
    $lineres{location}        = $location;
    $lineres{'location-only'} = $location_only;

    # lets get a list on existing orders for all bibitems.
    my @bibitems = GetBiblioItemByBiblioNumber( $result->{biblionumber} );
    my $count1 = scalar @bibitems; 
    my $order, my $ordernumber;

    my $i1 = 0;

    my @ordernumbers;
    foreach my $bibitem (@bibitems) {

        ( $order, $ordernumber ) =
          &GetOrder($result->{biblionumber},$bibitem->{biblioitemnumber} );

        #only show order if its current;
        my %order;
        $order{'number'} = $ordernumber;
        if (   ( !$order->{cancelledby} )
            && ( $order->{quantityreceived} < $order->{quantity} ) )
        {
            push @ordernumbers, \%order;
        }
    }
    $lineres{existingorder} = \@ordernumbers;
    push( @loopresult, \%lineres );
    $i++;
}

my $prevoffset = $offset - $num;
my $offsetprev = 1;
if ( $prevoffset < 0 ) {
    $offsetprev = 0;
}

$offset = $num + $offset;

my @numbers = ();
if ( $count > 10 ) {
    for ( my $i = 0 ; $i < ( $count / $num ) ; $i++ ) {
        my $highlight    = 0;
        my $numberoffset = $i * $num;
        if ( ( $numberoffset + $num ) == $offset ) { $highlight = 1 }

     #       warn "I $i | N $num | O $offset | NO $numberoffset | H $highlight";
        push @numbers,
          {
            number       => ( $i + 1 ),
            highlight    => $highlight,
            numberoffset => $numberoffset
          };
    }
}

$template->param(
    bookselname            => $booksellers[0]->{'name'},
    booksellerid           => $booksellerid,
    basketno               => $basketno,
    parsub                 => $sub,
    count                  => $count,
    offset2                => $offset2,
    dispnum                => $dispnum,
    offsetover             => ( $offset < $count ),
    num                    => $num,
    offset                 => $prevoffset,
    offsetprev             => $offsetprev,
    type                   => $type,
    title                  => $title,
    author                 => $author,
    donation               => $donation,
    loopsearch             => \@loopsearch,
    loopresult             => \@loopresult,
    numbers                => \@numbers,
    invalidsearch          => $invalidsearch,
    'use-location-flags-p' => 1
);

output_html_with_http_headers $input, $cookie, $template->output;

