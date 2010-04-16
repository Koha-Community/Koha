#!/usr/bin/perl

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
use CGI;
use C4::Auth;
use C4::Serials;
use C4::Acquisition;
use C4::Output;
use C4::Context;

# use Date::Manip;
use Text::CSV_XS;


# &Date_Init("DateFormat=non-US"); # set non-USA date, eg:19/08/2005


my $csv = Text::CSV_XS->new(
        {
            'quote_char'  => '"',
            'escape_char' => '"',
            'sep_char'    => ',',
            'binary'      => 1
        }
    );


my $query = new CGI;
my $supplierid = $query->param('supplierid');
my @serialid = $query->param('serialid');
my $op = $query->param('op') || q{};
my $serialidcount = @serialid;

my @loop1;
my @lateissues;
if($op ne 'claims'){
    @lateissues = GetLateIssues($supplierid);
    for my $issue (@lateissues){
        push @loop1,
      [ $issue->{'name'}, $issue->{'title'}, $issue->{'serialseq'}, $issue->{'planneddate'},];
    }
}
my $totalcount2 = 0;
my @loop2;
my @missingissues;
for (my $k=0;$k<@serialid;$k++){
    @missingissues = GetLateOrMissingIssues($supplierid, $serialid[$k]);

    for (my $j=0;$j<@missingissues;$j++){
	my @rows2 = ($missingissues[$j]->{'name'},          # lets build up a row
	             $missingissues[$j]->{'title'},
                     $missingissues[$j]->{'serialseq'},
                     $missingissues[$j]->{'planneddate'},
                     );
        push (@loop2, \@rows2);
    }
    $totalcount2 += scalar @missingissues;
    # update claim date to let one know they have looked at this missing item
    updateClaim($serialid[$k]);
}

my $heading ='';
my $filename ='';
if($supplierid){
    if($missingissues[0]->{'name'}){ # if exists display supplier name in heading for neatness
	# not necessarily needed as the name will appear in supplier column also
        $heading = "FOR $missingissues[0]->{'name'}";
	$filename = "_$missingissues[0]->{'name'}";
    }
}

print $query->header(
        -type       => 'application/vnd.ms-excel',
        -attachment => "claims".$filename.".csv",
    );

if($op ne 'claims'){
    print "LATE ISSUES ".$heading."\n\n";
    print "SUPPLIER,TITLE,ISSUE NUMBER,LATE SINCE\n";

    for my $row ( @loop1 ) {

        $csv->combine(@$row);
        my $string = $csv->string;
        print $string, "\n";
    }

    print ",,,,,,,\n\n";
}
if($serialidcount == 1){
    print "MISSING ISSUE ".$heading."\n\n";
} else {
    print "MISSING ISSUES ".$heading."\n\n";
}
print "SUPPLIER,TITLE,ISSUE NUMBER,LATE SINCE\n";

for my $row ( @loop2 ) {

        $csv->combine(@$row);
        my $string = $csv->string;
        print $string, "\n";
    }

print ",,,,,,,\n";
print ",,,,,,,\n";
if($op ne 'claims'){
    my $count = scalar @lateissues;
    print ",,Total Number Late, $count\n";
}
if($serialidcount == 1){

} else {
    print ",,Total Number Missing, $totalcount2\n";
}
