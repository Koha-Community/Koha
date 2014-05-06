#!/usr/bin/perl

# script to find a guarantor

# Copyright 2006 OUEST PROVENCE
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

use Modern::Perl;

use CGI;

use C4::Auth;
use C4::Output;
use C4::Dates qw/format_date/;
use C4::Members;

my $input = new CGI;
my ( $template, $loggedinuser, $cookie );

( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "members/guarantor_search.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { borrowers => 1 },
        debug           => 1,
    }
);

my $member        = $input->param('member') // '';
my $orderby       = $input->param('orderby');
my $category_type = $input->param('category_type');

$orderby = "surname,firstname" unless $orderby;
$member =~ s/,//g;     #remove any commas from search string
$member =~ s/\*/%/g;

$template->param( results => $member );

my $search_category = 'A';
if ( $category_type eq 'P' ) {
    $search_category = 'I';
}

my ( $count, $results );
my @resultsdata;

if ( $member ne '' ) {
    $results =
      Search( { '' => $member, category_type => $search_category }, $orderby );

    $count = $results ? @$results : 0;

    for ( my $i = 0 ; $i < $count ; $i++ ) {
        my %row = (
            count          => $i + 1,
            borrowernumber => $results->[$i]{'borrowernumber'},
            cardnumber     => $results->[$i]{'cardnumber'},
            surname        => $results->[$i]{'surname'},
            firstname      => $results->[$i]{'firstname'},
            categorycode   => $results->[$i]{'categorycode'},
            streetnumber   => $results->[$i]{'streetnumber'},
            address        => $results->[$i]{'address'},
            address2       => $results->[$i]{'address2'},
            city           => $results->[$i]{'city'},
            state          => $results->[$i]{'state'},
            zipcode        => $results->[$i]{'zipcode'},
            country        => $results->[$i]{'country'},
            branchcode     => $results->[$i]{'branchcode'},
            dateofbirth    => format_date( $results->[$i]{'dateofbirth'} ),
            borrowernotes  => $results->[$i]{'borrowernotes'}
        );

        push( @resultsdata, \%row );
    }
}

$template->param(
    member        => $member,
    numresults    => $count,
    category_type => $category_type,
    resultsloop   => \@resultsdata
);

output_html_with_http_headers $input, $cookie, $template->output;
