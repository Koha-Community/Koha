#!/usr/bin/perl

# Display a history of attempts to contact this borrower
# regarding overdues and fines.
#
# Tony McCrae
# tony@katipo.co.nz 	5/July/2003
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

#use lib ('/usr/local/koha/intranet/modules');
use strict;
use CGI;
use HTML::Template;
use C4::Database;
use C4::Search;
use C4::Circulation::Circ2;
use C4::Circulation::Fines;

use Data::Dumper;

my $input = new CGI;
my $bornum = $input->param('bornum');
my $date= $input->param('date');
my $edate=$input->param('edate');
print $input->header;
if ($bornum) {
	my $borrower = BorType($bornum);
	

	my $querystring = "	select	date, method, address, result, message, borrowernumber
					from attempted_contacts
        where date >= ? and date < ?
					";
        

	my $dbh=C4Connect();    
	my $sth=$dbh->prepare($querystring);
	$sth->execute($date,$edate);

	while (my $row=$sth->fetchrow_hashref()) {
	        print "<a href=/cgi-bin/koha/moremember.pl?bornum=$row->{'borrowernumber'}>Borrwer Record</a> ";
	        if ($row->{'method'} ne 'email'){
		    my $tidydate=$row->{'date'};
		    $tidydate=~ s/ /%20/g;
		    print " &nbsp; <a href=/cgi-bin/koha/printnote.pl?bornum=$row->{'borrowernumber'}&date=$tidydate>Print Note</a><br>";
		    }
		print $row->{'date'}."<br>\n";
		print $row->{'method'}."<br>\n";
		print $row->{'address'}."<br>\n";
		print $row->{'result'}."<br>\n";
		print $row->{'message'}."<br>\n";
	    	print "<p><p>";
		}

	}



