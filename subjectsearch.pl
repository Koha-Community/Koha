#!/usr/bin/perl

#script to display detailed information
#written 8/11/99

use strict;
#use DBI;
use C4::Search;
use CGI;
use C4::Output;

my $input = new CGI;
print $input->header;
my $type=$input->param('type');
print startpage();
print startmenu($type);
my $blah;
my $env;
my $subject=$input->param('subject');
#my $title=$input->param('title');

my $main;                                                                                                                                 
my $secondary;                                                                                                                            
if ($type eq 'opac'){                                                                                                                     
  $main='#99cccc';                                                                                                                        
  $secondary='#efe5ef';                                                                                                                   
} else {                                                                                                                                  
  $main='#99cc33';                                                                                                                        
  $secondary='#ffffcc';                                                                                                                   
}      

my @items=subsearch(\$blah,$subject);
#print @items;
my $count=@items;
my $i=0;
print center();
print mktablehdr;
if ($type ne 'opac'){
  print mktablerow(5,$main,bold('TITLE'),bold('AUTHOR'),bold('COUNT'),bold('LOCATION'),' ',"/images/background-mem.gif"); 
} else {
  print mktablerow(5,$main,bold('TITLE'),bold('AUTHOR'),bold('COUNT'),bold('BRANCH'),' &nbsp; '); 
}
my $colour=1;
while ($i < $count){
  my @results=split('\t',$items[$i]);
  $results[0]=mklink("/cgi-bin/koha/detail.pl?bib=$results[2]&type=$type",$results[0]);
  my $word=$results[1];
  $word=~ s/ //g;
  $word=~ s/\,/\,%20/;
  $results[1]=mklink("/cgi-bin/koha/search.pl?author=$word&type=$type",$results[1]);
  my ($count,$lcount,$nacount,$fcount,$scount)=itemcount($env,$results[2]);                                                                     
  $results[3]=$count;                                                                                                                           
  if ($nacount > 0){                                                                                                                          
    $results[4]=$results[4]."On Loan";                                                                                                          
    if ($nacount > 1){
      $results[4].=" $nacount";
    }
    $results[4].=" ";
  }                                                                                                                                           
  if ($lcount > 0){                                                                                                                           
    $results[4]=$results[4]." Levin";                                                                                                          
    if ($lcount > 1){
      $results[4].=" $lcount";
    }
    $results[4].=" ";
  }                                                                                                                                           
  if ($fcount > 0){                                                                                                                           
    $results[4]=$results[4]." Foxton";                                                                                                          
    if ($fcount > 1){
      $results[4].=" $fcount";
    }
    $results[4].=" ";
  }                                                                                                                                           
  if ($scount > 0){                                                                                                                           
    $results[4]=$results[4]." Shannon";                                                                                                          
    if ($scount > 1){
      $results[4].=" $scount";
    }
    $results[4].=" ";
  }             
  if ($type ne 'opac'){
    $results[6]=mklink("/cgi-bin/koha/request.pl?bib=$results[2]","Request");
  }
  if ($colour == 1){                                                                          
    print mktablerow(5,$secondary,$results[0],$results[1],$results[3],$results[4],$results[6]);                                        
    $colour=0;                                                                   
  } else{                                                                        
    print mktablerow(5,'white',$results[0],$results[1],$results[3],$results[4],$results[6]);                                     
    $colour=1;                                                                                
  }
   $i++;
}
print endcenter();
print mktableft();
print endmenu($type);
print endpage();
