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
use C4::Biblio;
# use C4::Search;
use C4::Breeding;
use C4::SearchMarc;
use C4::Output;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Koha;

my $input      = new CGI;
my $offset     = $input->param('offset');
my $num        = $input->param('num');
# my $total;
# my $count;
# my @results;
my $marc_p = C4::Context->boolean_preference("marc");
my $dbh = C4::Context->dbh;

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "acqui.simple/isbnsearch.tmpl",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { editcatalogue => 1 },
            debug           => 1,
        }
    );

    # fill with books in ACTIVE DB (biblio)
    if ( !$offset ) {
        $offset     = 0;
    }
    if ( !$num ) { $num = 10 }
	my @marclist = $input->param('marclist');
	my @and_or = $input->param('and_or');
	my @excluding = $input->param('excluding');
	my @operator = $input->param('operator');
	my @value = $input->param('value');
	my $title= @value[0];
	my $isbn = @value[1];
	my $resultsperpage= $input->param('resultsperpage');
	$resultsperpage = 5 if(!defined $resultsperpage);
	my $startfrom=$input->param('startfrom');
	$startfrom=0 if(!defined $startfrom);
	my $orderby = $input->param('orderby');
	my $desc_or_asc = $input->param('desc_or_asc');

	# builds tag and subfield arrays
	my @tags;

	foreach my $marc (@marclist) {
		if ($marc) {
			my ($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,$marc,'');
			if ($tag) {
				push @tags,$dbh->quote("$tag$subfield");
			} else {
				push @tags, $dbh->quote(substr($marc,0,4));
			}
		} else {
			push @tags, "";
		}
	}
	findseealso($dbh,\@tags);
	my ($results,$total) = catalogsearch($dbh, \@tags,\@and_or,
										\@excluding, \@operator, \@value,
										$startfrom, $resultsperpage,'biblio.title','ASC');
# 	@results = @$resultsref;

#     my @loop_data = ();
#     my $toggle;
#     for ( my $i = $offset ; $i < $total ; $i++ ) {
#         if ( $i % 2 ) {
#             $toggle = 0;
#         } else {
#             $toggle = 1;
#         }
#         my %row_data;    # get a fresh hash for the row data
#         $row_data{toggle}        = $toggle;
#         $row_data{biblionumber}  = $results[$i]->{'biblionumber'};
#         $row_data{title}         = $results[$i]->{'title'};
#         $row_data{author}        = $results[$i]->{'author'};
#         $row_data{copyrightdate} = $results[$i]->{'copyrightdate'};
# 		$row_data{classification} = $results[$i]->{'classification'};
#         $row_data{NOTMARC}       = !$marc_p;	
#         push ( @loop_data, \%row_data );
#     }
	# multi page display gestion
	my $displaynext=0;
	my $displayprev=$startfrom;
	if(($total - (($startfrom+1)*($resultsperpage))) > 0 ) {
		$displaynext = 1;
	}

	my @field_data = ();

	for(my $i = 0 ; $i <= $#marclist ; $i++) {
		push @field_data, { term => "marclist", val=>$marclist[$i] };
		push @field_data, { term => "and_or", val=>$and_or[$i] };
		push @field_data, { term => "excluding", val=>$excluding[$i] };
		push @field_data, { term => "operator", val=>$operator[$i] };
		push @field_data, { term => "value", val=>$value[$i] };
	}

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
            $toggle = 0;
        } else {
            $toggle = 1;
        }
        my %row_data;    # get a fresh hash for the row data
        $row_data{toggle}        = $toggle;
        $row_data{biblionumber}  = $results[$i]->{'biblionumber'};
        $row_data{title}         = $results[$i]->{'title'};
        $row_data{author}        = $results[$i]->{'author'};
        $row_data{copyrightdate} = $results[$i]->{'copyrightdate'};
		$row_data{classification} = $results[$i]->{'classification'};
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
	my $toggle=0;
    my ( $countbr, @resultsbr ) = BreedingSearch( @value[0], @value[1] );
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
        $row_data{NOTMARC}= !$marc_p;	
        push ( @breeding_loop, \%row_data );
    }

	# get framework list
	my $frameworks = getframeworks;
	my @frameworkcodeloop;
	foreach my $thisframeworkcode (keys %$frameworks) {
		my %row =(value => $thisframeworkcode,
					frameworktext => $frameworks->{$thisframeworkcode}->{'frameworktext'},
				);
		push @frameworkcodeloop, \%row;
	}

    $template->param(
		title		  => $title,
		isbn		  => $isbn,
							startfrom=> $startfrom,
							displaynext=> $displaynext,
							displayprev=> $displayprev,
							resultsperpage => $resultsperpage,
							startfromnext => $startfrom+1,
							startfromprev => $startfrom-1,
							searchdata=>\@field_data,
							numbers=>\@numbers,
							from => $from,
							to => $to,
        total         => $total,
#         offset        => $offset,
        loop          => $results,
        breeding_loop => \@breeding_loop,
        NOTMARC       => !$marc_p,
		frameworkcodeloop => \@frameworkcodeloop,
    );

    print $input->header(
        -type   => guesstype( $template->output ),
        -cookie => $cookie
      ),
      $template->output;