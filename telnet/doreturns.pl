#!/usr/bin/perl

use DBI;
use C4::Database;
use C4::Accounts;
use C4::InterfaceCDK;
use C4::Circulation::Main;
use C4::Format;
use C4::Scan;
use C4::Stats;
use C4::Search;
use C4::Print;
use C4::Circulation::Returns;


my %env = (                                                                                      
branchcode => $ARGV[0], usercode => $ARGV[1], proccode => "lgon", borrowernumber => "",        
logintime  => "", lasttime => "", tempuser => "", debug => "9",                                
telnet => $ARGV[2], queue => $ARGV[3], printtype => $ARGV[4], brdata => $ARGV[5]               
);  
my $env=\%env;


my $dbh=&C4Connect;
my @items;
@items[0]=" "x50;
my $reason;
my $item;
my $reason;
my $borrower;
my $itemno;
my $itemrec;
my $bornum;
my $amt_owing;
my $odues;
my $issues;
my $resp;
startint();
until ($reason ne "") {
  ($reason,$item) = returnwindow($env,"Enter Returns",$item,\@items,$borrower,$amt_owing,$odues,$dbh,$resp); #C4::Circulation                                                        
  if ($reason eq "")  {
    $resp = "";                                                                                                                    
    ($resp,$bornum,$borrower,$itemno,$itemrec,$amt_owing) = C4::Circulation::Returns::checkissue($env,$dbh,$item);                                                                                                
    if ($bornum ne "") {                                                                                                           
      ($issues,$odues,$amt_owing) = borrdata2($env,$bornum);                                                                      
    } else {                                                                                                                       
      $issues = "";                                                                                                                
      $odues = "";                                                                                                                 
      $amt_owing = "";                                                                                                             
    }                                                                                                                              
    if ($resp ne "") {                                                                                                             
      if ($itemno ne "" ) {                                                                                                        
        my $item = itemnodata($env,$dbh,$itemno);                                                                                  
	my $fmtitem = C4::Circulation::Issues::formatitem($env,$item,"",$amt_owing);                                               
	unshift @items,$fmtitem;                                                                                                   
	if ($items[20] > "") {                                                                                                     
	  pop @items;                                                                                                              
	}                                                                                                                          
      }                                                                                                                            
    }                                                                                                                              
  }                                                                                                                                
}                                                                                                                                  
die;
$dbh->disconnect;                                                                                                                  


