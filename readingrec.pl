#!/usr/bin/perl

#written 27/01/2000
#script to display borrowers reading record


use strict;
use C4::Output;
use CGI;
use C4::Search;
my $input=new CGI;


my $bornum=$input->param('bornum');
#get borrower details
my $data=borrdata('',$bornum);
my ($count,$issues)=allissues($bornum);


print $input->header;
print startpage();
print startmenu('member');
#print $count;
print mkheadr(3,"$data->{'title'} $data->{'initials'} $data->{'surname'}");
print mktablehdr();
print mktablerow(4,'white',bold('TITLE'),bold('AUTHOR'),bold('DATE'));
for (my $i=0;$i<$count;$i++){
  print mktablerow(3,'white',$issues->[$i]->{'title'},$issues->[$i]->{'author'},$issues->[$i]->{'returndate'});
}
print mktableft();
print endmenu('member');
print endpage();

