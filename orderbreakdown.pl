#!/usr/bin/perl

#script to display info about acquisitions
#written by chris@katipo.co.nz 31/01/2000

use C4::Acquisitions;
use C4::Output;
use CGI;
my $input=new CGI;
print $input->header();
my $id=$input->param('id');
my ($count,$order)=breakdown($id);
print startpage;
print mktablehdr;
#print $id;
for (my$i=0;$i<$count;$i++){
print mktablerow(5,'white',"<b>Ordernumber:</b>$order->[$i]->{'ordernumber'}",
"<b>Line umber</b>:$order->[$i]->{'linenumber'}","<b>Branch Code:</b>$order->[$i]->{'branchcode'}",
"<b>Bookfundid</b>:$order->[$i]->{'bookfundid'}","<b>Allocation:</b>$order->[$i]->{'allocation'}");
}
print mktableft;
print endpage;
