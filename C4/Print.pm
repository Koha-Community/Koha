package C4::Print; #assumes C4/Print.pm

use strict;
require Exporter;
#use C4::InterfaceCDK;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&remoteprint &printreserve);

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
#    print $i;
    my $itemdata = $items->[$i];
    print PRINTER "$i $itemdata->{'title'}\r\n";
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
  
    
