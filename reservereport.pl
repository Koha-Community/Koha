#!/usr/bin/perl

#written 26/4/2000
#script to display reports

use C4::Stats;
use strict;
use Date::Manip;
use CGI;
use C4::Output;

my $input=new CGI;
my $time=$input->param('time');
print $input->header;

print startpage;
print startmenu('report');
print center;
print mktablehdr();
my ($count,$data)=unfilledreserves();
print $count;
for (my $i=0;$i<$count;$i++){
  print mktablerow(4,'white',"$data->[$i]->{'surname'}\, $data->[$i]->{'firstname'}",$data->[$i]->{'reservedate'},$data->[$i]->{'title'},"$data->[$i]->{'classification'}$data->[$i]->{'dewey'}");
}
print mktableft();
print endmenu('report');
print endpage;
