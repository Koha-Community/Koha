#!/usr/bin/perl

#my @args=('issuewrapper.pl',"$env{'branchcode'}","$env{'usercode'}","$env{'telnet'}","$env{'queue'}","$env{'printtype'}");

$done = "Issues";                                                                
my $i=0;
my $bcard;
while ($done eq "Issues") {                                                      
  my @args=('borrwraper.pl',@ARGV,$bcard);
  my $time=localtime(time);
  open (FILE,">>/tmp/$<_$ARGV[6]");
  print FILE "new borrower $time\n";
  close FILE;
  eval{$bcard=system(@args)};
  $exit_value  = $? >> 8;
  if ($exit_value){
    $done=$exit_value;
  }

}                                                                                
