package C4::Print; #assumes C4/Print.pm


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
require Exporter;
#use C4::InterfaceCDK;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&remoteprint &printreserve &printslip);


sub remoteprint {
  my ($env,$items,$borrower)=@_;
  #open (FILE,">/tmp/olwen");
  #print FILE "queue $env->{'queue'}";
  #close FILE;
  #debug_msg($env,"In print");
  my $file=time;
  my $queue = $env->{'queue'};
  if ($queue eq "" || $queue eq 'nulllp') {
    open (PRINTER,">/tmp/kohaiss");
  } else {  
    open(PRINTER, "| lpr -P $queue") or die "Couldn't write to queue:$queue!\n";
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
  my($env, $branchname, $bordata, $itemdata)=@_;
  my $file=time;
  my $printer = $env->{'printer'};
  if ($printer eq "" || $printer eq 'nulllp') {
    open (PRINTER,">>/tmp/kohares");
  } else {
    open (PRINTER, "| lpr -P $printer") or die "Couldn't write to queue:$!\n";
  }
  my @da = localtime(time());
  my $todaysdate = "$da[2]:$da[1]  $da[3]/$da[4]/$da[5]";

#(1900+$datearr[5]).sprintf ("%0.2d", ($datearr[4]+1)).sprintf ("%0.2d", $datearr[3]);
  my $slip = <<"EOF";
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Date: $todaysdate;

ITEM RESERVED: 
$itemdata->{'title'} ($itemdata->{'author'})
barcode: $itemdata->{'barcode'}

COLLECT AT: $branchname

BORROWER:
$bordata->{'surname'}, $bordata->{'firstname'}
card number: $bordata->{'cardnumber'}
Phone: $bordata->{'phone'}
$bordata->{'streetaddress'}
$bordata->{'suburb'}
$bordata->{'town'}
$bordata->{'emailaddress'}


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EOF
    print PRINTER $slip;
  close PRINTER;
  return $slip;
}

sub printslip {
  my($env, $slip)=@_;
  my $printer = $env->{'printer'};
  if ($printer eq "" || $printer eq 'nulllp') {
    open (PRINTER,">/tmp/kohares");
  } else {
    open (PRINTER, "| lpr -P $printer") or die "Couldn't write to queue:$!\n";
  }
  print PRINTER $slip;
  close PRINTER;
}

END { }       # module clean-up code here (global destructor)
  
    
