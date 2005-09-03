#!/usr/bin/perl
use strict;
require Exporter;
use CGI;

use C4::Auth;
use C4::Koha;
use HTML::Template;
use C4::Interface::CGI::Output;
use C4::Search;
use C4::Circulation::Circ2;
use C4::Review;

my $query = new CGI;
my $biblionumber = $query->param('biblionumber');
my $type = $query->param('type');
my $review = $query->param('review');
my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-review.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 0,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });

# get borrower information ....
# my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);
# $template->param($borr);

my $biblio=bibdata($biblionumber,'opac');

my $savedreview=getreview($biblionumber,$borrowernumber);
if ($type eq 'save'){
   savereview($biblionumber,$borrowernumber,$review);    
}
if ($type eq 'update'){
    updatereview($biblionumber,$borrowernumber,$review);
}
if ($savedreview){
	$type="update";
    }
else {
    $type="save";
}
my $reviewdata=$savedreview->{'review'};
$template->param('biblionumber' => $biblionumber,
    'borrowernumber' => $borrowernumber,
    'type'=>$type,
    'review'=>$reviewdata,
    'title'=>$biblio->{'title'});

# get the record
my $order=$query->param('order');
my $order2=$order;
if ($order2 eq ''){
  $order2="date_due desc";
}
my $limit=$query->param('limit');
if ($limit eq 'full'){
  $limit=0;
} else {
  $limit=50;
}

output_html_with_http_headers $query, $cookie, $template->output;

