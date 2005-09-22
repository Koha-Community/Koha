#!/usr/bin/perl
use strict;
require Exporter;
use CGI;

use C4::Auth;
use C4::Koha;
use C4::Circulation::Circ2;
use C4::Date;
use C4::Members;
use HTML::Template;
use C4::Interface::CGI::Output;

my $query = new CGI;
my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-readingrecord.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 0,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });

# get borrower information ....
my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);


$template->param($borr);

# get the record
my $order=$query->param('order');
my $order2=$order;
if ($order2 eq ''){
  $order2="date_due desc";
  $template->param(orderbydate => 1);
}

if($order2 eq 'title'){
	$template->param(orderbytitle => 1);
	}

if($order2 eq 'author'){
	$template->param(orderbyauthor => 1);
}

my $limit=$query->param('limit');
if ($limit eq 'full'){
  $limit=0;
} else {
  $limit=50;
}
my ($count,$issues)=allissues($borrowernumber,$order2,$limit);

# add the row parity
#my $num = 0;
#foreach my $row (@$issues) {
#    $row->{'even'} = 1 if $num % 2 == 0;
#    $row->{'odd'} = 1 if $num % 2 == 1;
#    $num++;
#}

my @loop_reading;

for (my $i=0;$i<$count;$i++){
 	my %line;
	if($i%2){
		$line{'toggle'} = 1;
	}
	$line{biblionumber}=$issues->[$i]->{'biblionumber'};
	$line{title}=$issues->[$i]->{'title'};
	$line{author}=$issues->[$i]->{'author'};
	$line{classification} = $issues->[$i]->{'classification'};
	$line{date_due}=format_date($issues->[$i]->{'date_due'});
	$line{returndate}=format_date($issues->[$i]->{'returndate'});
	$line{volumeddesc}=$issues->[$i]->{'volumeddesc'};
	$line{counter} = $i + 1;
	push(@loop_reading,\%line);
}

$template->param(count => $count);
$template->param(READING_RECORD => \@loop_reading,
				limit => $limit,
				showfulllink => ($count > 50),		
			     LibraryName => C4::Context->preference("LibraryName"),
				suggestion => C4::Context->preference("suggestion"),
				virtualshelves => C4::Context->preference("virtualshelves"),
);


output_html_with_http_headers $query, $cookie, $template->output;

