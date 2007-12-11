#!/usr/bin/perl

use strict;
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
my $op = $query->param('op');
my $serialidcount = @serialid;

my %supplierlist = GetSuppliersWithLateIssues;
my @select_supplier;

my @loop1;
my ($count, @lateissues);
if($op ne 'claims'){
    ($count, @lateissues) = GetLateIssues($supplierid);
    for (my $i=0;$i<@lateissues;$i++){
        my @rows1 = ($lateissues[$i]->{'name'},          # lets build up a row
            	     $lateissues[$i]->{'title'}, 
                     $lateissues[$i]->{'serialseq'},
                     $lateissues[$i]->{'planneddate'},
                     );
        push (@loop1, \@rows1);
    }
}
my $totalcount2 = 0;
my @loop2;
my ($count2, @missingissues);
for (my $k=0;$k<@serialid;$k++){
    ($count2, @missingissues) = GetLateOrMissingIssues($supplierid, $serialid[$k]);

    for (my $j=0;$j<@missingissues;$j++){
	my @rows2 = ($missingissues[$j]->{'name'},          # lets build up a row
	             $missingissues[$j]->{'title'}, 
                     $missingissues[$j]->{'serialseq'},
                     $missingissues[$j]->{'planneddate'},
                     );
        push (@loop2, \@rows2);
    }
    $totalcount2 = $totalcount2 + $count2;
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
    print ",,Total Number Late, $count\n";
}
if($serialidcount == 1){

} else {
    print ",,Total Number Missing, $totalcount2\n";
}
