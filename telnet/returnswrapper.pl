#!/usr/bin/perl

$done = "returns";                                                                
my $i=0;
while ($done eq "returns") {                                                      
  my @args=('doreturns.pl',@ARGV);
  eval{system(@args)};
  $exit_value  = $? >> 8;
  if ($exit_value){
    $done=$exit_value;
  }

}                                                                                
