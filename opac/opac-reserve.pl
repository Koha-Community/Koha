#!/usr/bin/perl
use strict;
require Exporter;
use CGI;

use C4::Search;
use C4::Output;       # gettemplate
use C4::Auth;         # checkauth, getborrowernumber.
use C4::Koha;
use C4::Circulation::Circ2;
use C4::Reserves2;

my $query = new CGI;


my ($loggedinuser, $cookie, $sessionID) = checkauth($query);

my $template = gettemplate("opac-reserve.tmpl", "opac");

# get borrower information ....
my $borrowernumber = getborrowernumber($loggedinuser);
my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);
my @bordat;
$bordat[0] = $borr;
$template->param(BORROWER_INFO => \@bordat);

# get biblionumber.....
my $biblionumber = $query->param('bib');
$template->param(biblionumber => $biblionumber);

my $bibdata = bibdata($biblionumber);
$template->param($bibdata);

# get the rank number....
my ($rank,$reserves) = FindReserves($biblionumber);
foreach my $res (@$reserves) {
    if ($res->{'found'} eq 'W') {
	$rank--;
    }
}
$rank++;
$template->param(rank => $rank);



# pass the pickup branch along....
my $branch = $query->param('branch');
$template->param(branch => $branch);

my $branches = getbranches();
$template->param(branchname => $branches->{$branch}->{'branchname'});


# make branch selection options...
my $branchoptions = '';
foreach my $br (keys %$branches) {
    (next) unless $branches->{$br}->{'IS'};
    my $selected = "";
    if ($br eq $branch) {
	$selected = "selected";
    }
    $branchoptions .= "<option value=$br $selected>$branches->{$br}->{'branchname'}</option>\n";
}
$template->param( branchoptions => $branchoptions);


#get the bibitem data....
my ($count,@data) = bibitems($biblionumber);

foreach my $bibitem (@data) {
    my @barcodes = barcodes($bibitem->{'biblioitemnumber'});
    my $barcodestext = "";
    foreach my $num (@barcodes) {
	my $message = $num->{'itemlost'} == 1 ? "(lost)" :
	    $num->{'itemlost'} == 2 ? "(long overdue)" : "($branches->{$num->{'holdingbranch'}}->{'branchname'})";
	$barcodestext .= "$num->{'barcode'} $message <br>";
    }
    $barcodestext = substr($barcodestext, 0, -4);
    $bibitem->{'copies'} = $barcodestext;
}



my @reqbibs = $query->param('reqbib');
if ($query->param('bibitemsselected')) {
    $template->param(bibitemsselected => 1);
    my @tempdata;
    foreach my $bibitem (@data) {
	foreach my $reqbib (@reqbibs){
	    push @tempdata, $bibitem if ($bibitem->{'biblioitemnumber'} == $reqbib) ;
	}
    }
    @data = @tempdata;
} elsif ($query->param('placereserve')) {
# here we actually do the reserveration....
    my $title = $bibdata->{'title'};
    CreateReserve(undef,$branch,$borrowernumber,$biblionumber,'o',\@reqbibs,$rank,'',$title);
    warn "reserve created\n";
    print $query->redirect("/cgi-bin/koha/opac-user.pl");
} else {
    $template->param(selectbibitems => 1);
}
# check that you can actually make the reserve.



$template->param(BIBLIOITEMS => \@data);

$template->param(loggedinuser => $loggedinuser);
print "Content-Type: text/html\n\n", $template->output;
