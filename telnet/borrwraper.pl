#!/usr/bin/perl

use DBI;
use C4::Database;
use C4::Circulation::Issues;
use C4::Circulation::Main;
use C4::InterfaceCDK;
use C4::Circulation::Borrower;

# my @args=('issuewrapper.pl',"$env{'branchcode'}","$env{'usercode'}","$env{'telnet'}","$env{'queue'}","$env{'printtype'}");
my %env = (
  branchcode => $ARGV[0], usercode => $ARGV[1], proccode => "lgon", borrowernumber => "",
  logintime  => "", lasttime => $ARGV[6], tempuser => "", debug => "9",
  telnet => $ARGV[2], queue => $ARGV[3], printtype => $ARGV[4], brdata => $ARGV[5], bcard=>$ARGV[7]
      );
my ($env) = \%env;                                                                  

startint();
  helptext('');                                                                    
my $done;                                                                        
my ($items,$items2,$amountdue);                                                  
my $itemsdet;                                                                    
$env->{'sysarea'} = "Issues";                                                    
$done = "Issues";                                                                
my $i=0;
my $dbh=&C4Connect;                                                              
  my ($bornum,$issuesallowed,$borrower,$reason,$amountdue) = C4::Circulation::Borrower::findborrower($env,$dbh);
#    my $time=localtime(time);                                                     
#    open (FILE,">>/tmp/$<_$ARGV[6]");                                             
#    print FILE "borrower found $bornum";
#    close FILE;
  $env->{'loanlength'}="";                                                       
  if ($reason ne "") {                                                           
    $done = $reason;                                                             
  } elsif ($env->{'IssuesAllowed'} eq '0') {                                     
    error_msg($env,"No Issues Allowed =$env->{'IssuesAllowed'}");                
  } else {                                                                       
    $env->{'bornum'} = $bornum;                                                  
    $env->{'bcard'}  = $borrower->{'cardnumber'};                                
    ($items,$items2)=C4::Circulation::Main::pastitems($env,$bornum,$dbh); #from Circulation.pm    
    $done = "No";                                                                
    my $it2p=0;                                                                  
    while ($done eq 'No'){                                                       
      ($done,$items2,$it2p,$amountdue,$itemsdet) = C4::Circulation::Issues::processitems($env,$bornum,$borrower,$items,$items2,$it2p,$amountdue,$itemsdet);                                    
    }                                                                            
    
  } 
  if ($done ne 'Issues'){
      $dbh->disconnect;                                                                
      die "test";
  }
$dbh->disconnect;                                                                
