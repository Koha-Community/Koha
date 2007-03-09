#!/usr/bin/perl

# $Id$

#
# Modified saas@users.sf.net 12:00 01 April 2001
# The biblioitemnumber was not correctly initialised
# The max(barcode) value was broken - koha 'barcode' is a string value!
# - If left blank, barcode value now defaults to max(biblionumber)

#
# TODO
#
# Add info on biblioitems and items already entered as you enter new ones
#
# Add info on biblioitems and items already entered as you enter new ones

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
use C4::Biblio;
use C4::Breeding;
use C4::Output;
use C4::Interface::CGI::Output;

use C4::Koha;
use C4::Search;

my $input = new CGI;

my $success = $input->param('biblioitem');
my $query   = $input->param('q');
my @value = $input->param('value');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "cataloguing/addbooks.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 1 },
        debug           => 1,
    }
);

# get framework list
my $frameworks = getframeworks;
my @frameworkcodeloop;
foreach my $thisframeworkcode (keys %$frameworks) {
	my %row =(value => $thisframeworkcode,
				frameworktext => $frameworks->{$thisframeworkcode}->{'frameworktext'},
			);
	push @frameworkcodeloop, \%row;
}

# Searching the catalog.
if($query) {
    my ($error, $marcresults) = SimpleSearch($query);

    if (defined $error) {
        $template->param(error => $error);
        warn "error: ".$error;
        output_html_with_http_headers $input, $cookie, $template->output;
        exit;
    }

    my $total = scalar @$marcresults;
    my @results;

    for(my $i=0;$i<$total;$i++) {
        my %resultsloop;
        my $marcrecord = MARC::File::USMARC::decode($marcresults->[$i]);
        my $biblio = MARCmarc2koha(C4::Context->dbh,$marcrecord,'');
    
        #hilight the result
        $biblio->{'title'} =~ s/$query/<span class=term>$&<\/span>/gi;
        $biblio->{'subtitle'} =~ s/$query/<span class=term>$&<\/span>/gi;
        $biblio->{'biblionumber'} =~ s/$query/<span class=term>$&<\/span>/gi;
        $biblio->{'author'} =~ s/$query/<span class=term>$&<\/span>/gi;
        $biblio->{'publishercode'} =~ s/$query/<span class=term>$&<\/span>/gi;
        $biblio->{'publicationyear'} =~ s/$query/<span class=term>$&<\/span>/gi;
    
        #build the hash for the template.
        $resultsloop{highlight}       = ($i % 2)?(1):(0);
        $resultsloop{title}           = $biblio->{'title'};
        $resultsloop{subtitle}        = $biblio->{'subtitle'};
        $resultsloop{biblionumber}    = $biblio->{'biblionumber'};
        $resultsloop{author}          = $biblio->{'author'};
        $resultsloop{publishercode}   = $biblio->{'publishercode'};
        $resultsloop{publicationyear} = $biblio->{'publicationyear'};

        push @results, \%resultsloop;
    }
    $template->param(
        total => $total,
        query => $query,
        resultsloop => \@results,
    );
}

# fill with books in breeding farm
my $toggle=0;
my ($title,$isbn);
# fill isbn or title, depending on what has been entered
$isbn=$query if $query =~ /\d/;
$title=$query unless $isbn;
my ( $countbr, @resultsbr ) = BreedingSearch( $title, $isbn ) if $query;
my @breeding_loop = ();
for ( my $i = 0 ; $i <= $#resultsbr ; $i++ ) {
    my %row_data;
    if ( $i % 2 ) {
        $toggle = 0;
    }
    else {
        $toggle = 1;
    }
    $row_data{toggle} = $toggle;
    $row_data{id}     = $resultsbr[$i]->{'id'};
    $row_data{isbn}   = $resultsbr[$i]->{'isbn'};
    $row_data{file}   = $resultsbr[$i]->{'file'};
    $row_data{title}  = $resultsbr[$i]->{'title'};
    $row_data{author} = $resultsbr[$i]->{'author'};
    push ( @breeding_loop, \%row_data );
}

$template->param( frameworkcodeloop => \@frameworkcodeloop,
                  breeding_loop => \@breeding_loop,
              );

output_html_with_http_headers $input, $cookie, $template->output;
