#!/usr/bin/perl

#written 18/1/2000 by chris@katipo.co.nz
# adapted for use in the hlt opac by finlay@katipo.co.nz 29/11/2002
#script to renew items from the web

use CGI;
use C4::Circulation::Renewals2;

my $query = new CGI;

my $itemnumber = $query->param('item');
my $borrowernumber = $query->param("bornum");



my %env;
my $status = renewstatus(\%env,$borrowernumber,$itemnumber);
if ($status == 1){
    renewbook(\%env,$borrowernumber,$itemnumber);
}

if ($query->param('from') eq 'opac_user') {
    print $query->redirect("/cgi-bin/koha/opac-user.pl");
}
