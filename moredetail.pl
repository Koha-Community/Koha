#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Koha;
use CGI;
use C4::Search;
use C4::Acquisitions;
use C4::Output; # contains gettemplate
use C4::Auth;
  
my $query=new CGI;

my $flagsrequired;
$flagsrequired->{catalogue}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query, 0, $flagsrequired);

my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);


my $template=gettemplate('catalogue/moredetail.tmpl');

# get variables 

my $biblionumber=$query->param('bib');
my $title=$query->param('title');
my $bi=$query->param('bi');

my $data=bibitemdata($bi);
my $dewey = $data->{'dewey'};
$dewey =~ s/0+$//;
if ($dewey eq "000.") { $dewey = "";};
if ($dewey < 10){$dewey='00'.$dewey;}
if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}
if ($dewey <= 0){
      $dewey='';
}
$dewey=~ s/\.$//;
$data->{'dewey'}=$dewey;

my @results;

my (@items)=itemissues($bi);
my $count=@items;
$data->{'count'}=$count;
my ($order,$ordernum)=getorder($bi,$biblionumber);

my $env;
$env->{itemcount}=1;

$results[0]=$data;

foreach my $item (@items){
    $item->{'itemlost'}=~ s/0/No/;
    $item->{'itemlost'}=~ s/1/Yes/;
    $item->{'withdrawn'}=~ s/0/No/;
    $item->{'withdrawn'}=~ s/1/Yes/;
    $item->{'replacementprice'}+=0.00;
    my $year=substr($item->{'timestamp0'},0,4);
    my $mon=substr($item->{'timestamp0'},4,2);
    my $day=substr($item->{'timestamp0'},6,2);
    $item->{'timestamp0'}="$day/$mon/$year";
    $item->{'dateaccessioned'} = slashifyDate($item->{'dateaccessioned'});
    $item->{'datelastseen'} = slashifyDate($item->{'datelastseen'});
    if ($item->{'date_due'} = 'Available'){
	$item->{'issue'}="<b>Currently on issue to:</b><br>";
    } else {
	$item->{'issue'}="<b>Currently on issue to:</b> <a href=/cgi-bin/koha/moremember.pl?bornum=$item->{'borrower0'}>$item->{'card'}</a><br>";
    }
	  
}

$template->param(BIBITEM_DATA => \@results);
$template->param(ITEM_DATA => \@items);
$template->param(loggedinuser => $loggedinuser);
print "Content-Type: text/html\n\n", $template->output;

