
package C4::Print; #asummes C4/Print.pm

use strict;
require Exporter;
use C4::InterfaceCDK;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&remoteprint &printreserve);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);


# non-exported package globals go here
use vars qw(@more $stuff);

# initalize package globals, first exported ones

my $Var1   = '';
my %Hashit = ();


# then the others (which are still accessible as $Some::Module::stuff)
my $stuff  = '';
my @more   = ();

# all file-scoped lexicals must be created before
# the functions below that use them.

# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();

# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
  };
  
# make all your functions, whether exported or not;

sub remoteprint {
  my ($env,$items,$borrower)=@_;
  #open (FILE,">/tmp/olwen");
  #print FILE "queue $env->{'queue'}";
  #close FILE;
  #debug_msg($env,"In print");
  my $file=time;
  my $queue = $env->{'queue'};
  if ($queue eq "") {
    open (PRINTER,">/tmp/kohaiss");
  } else {  
    open(PRINTER, "| lpr -P $queue") or die "Couldn't write to queue:$!\n";
  }  
#  print $queue;
  #open (FILE,">/tmp/$file");
  my $i=0;
  my $brdata = $env->{'brdata'};
  print PRINTER "Horowhenua Library Trust\r\n";
#  print PRINTER "$brdata->{'branchname'}\r\n";
  print PRINTER "Phone: 368-1953\r\n";   
  print PRINTER "Fax:    367-9218\r\n";   
  print PRINTER "Email:  renewals\@library.org.nz\r\n\r\n\r\n";
  print PRINTER "$borrower->{'cardnumber'}\r\n";
  print PRINTER "$borrower->{'title'} $borrower->{'initials'} $borrower->{'surname'}\r\n";
  while ($items->[$i]){
    my $itemdata = $items->[$i];
    print PRINTER "$itemdata->{'title'}\r\n";
    print PRINTER "$itemdata->{'barcode'}";
    print PRINTER " "x15;
    print PRINTER "$itemdata->{'date_due'}\r\n";
    $i++;
  }
  print PRINTER "\r\n\r\n\r\n\r\n\r\n\r\n\r\n";
  if ($env->{'printtype'} eq "docket"){
    #print chr(27).chr(105);
  } 
  close PRINTER;
  #system("lpr /tmp/$file");
}

sub printreserve {
  my($env,$resrec,$rbordata,$itemdata)=@_;
  my $file=time;
  my $queue = $env->{'queue'};
  #if ($queue eq "") {
    open (PRINTER,">/tmp/kohares");
  #} else {
  #  open (PRINTER, "| lpr -P $queue") or die "Couldn't write to queue:$!\n";
  #}  
  print PRINTER "Collect at $resrec->{'branchcode'}\r\n\r\n";
  print PRINTER "$rbordata->{'surname'}; $rbordata->{'firstname'}\r\n";
  print PRINTER "$rbordata->{'cardnumber'}\r\n";
  print PRINTER "Phone: $rbordata->{'phone'}\r\n";
  print PRINTER "$rbordata->{'streetaddress'}\r\n";
  print PRINTER "$rbordata->{'suburb'}\r\n";
  print PRINTER "$rbordata->{'town'}\r\n";   
  print PRINTER "$rbordata->{'emailaddress'}\r\n\r\n";
  print PRINTER "$itemdata->{'barcode'}\r\n";
  print PRINTER "$itemdata->{'title'}\r\n";
  print PRINTER "$itemdata->{'author'}";
  print PRINTER "\r\n\r\n\r\n\r\n\r\n\r\n\r\n";
  if ($env->{'printtype'} eq "docket"){ 
    #print chr(27).char(105);
  }  
  close PRINTER;
  #system("lpr /tmp/$file"); 
}
END { }       # module clean-up code here (global destructor)
  
    
