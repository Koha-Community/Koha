package C4::Circmain; #assumes C4/Circulation

#package to deal with circulation 

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Circulation::Main;
use C4::Circulation::Issues;
use C4::Circulation::Returns;
use C4::Circulation::Renewals;
use C4::Circulation::Borrower;
use C4::Reserves;
use C4::InterfaceCDK;
use C4::Security;

use vars qw($VERSION @ISA @EXPORT);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&Start_circ);

sub Start_circ{
  my ($env)=@_;
  #connect to database
  #start interface
  &startint($env,'Circulation');
  getbranch($env);
  getprinter($env);
  my $donext = 'Circ';
  my $reason;
  my $data;
  while ($donext ne 'Quit') {
    if ($donext  eq "Circ") {
      #($reason,$data) = menu($env,'console','Circulation', 
      #  ('Issues','Returns','Borrower Enquiries','Reserves','Log In'));
      #&startint($env,"Menu");
      ($reason,$data) = menu($env,'console','Circulation',
        ('Issues','Returns','Select Branch','Select Printer')); 
    } else {
      $data = $donext;
    }
    if ($data eq 'Issues') {  
      $donext=Issue($env); #C4::Circulation::Issues 
    } elsif ($data eq 'Returns') {
      $donext=Returns($env); #C4::Circulation::Returns 
    } elsif ($data eq 'Select Branch') {
      getbranch($env);
    } elsif ($data eq 'Select Printer') {
      getprinter($env);      
    } elsif ($data eq 'Borrower Enquiries') {
      #  $donext=Borenq($env); #C4::Circulation::Borrower - conversion
    } elsif ($data eq 'Reserves'){
      $donext=EnterReserves($env); #C4::Reserves 
    } elsif ($data eq 'Quit') { 
      $donext = $data;
    }
  }
  &endint($env)  
}


END { }       # module clean-up code here (global destructor)





