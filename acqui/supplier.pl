#!/usr/bin/perl

# $Id$

#script to show display basket of orders
#written by chris@katipo.co.nz 24/2/2000


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

use C4::Auth;
use C4::Acquisition;
use C4::Biblio;
use C4::Output;
use CGI;
use C4::Interface::CGI::Output;
use C4::Database;
use HTML::Template;
use strict;

my $query=new CGI;
my $id=$query->param('supplierid');
my ($count,@booksellers)=bookseller($id);
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/supplier.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {acquisition => 1},
			     debug => 1,
			     });
#build array for currencies
my  ($count, $currencies) = &getcurrencies();
my @loop_pricescurrency;
my @loop_invoicecurrency;
for (my $i=0;$i<$count;$i++) {
	if ($booksellers[0]->{'listprice'} eq $currencies->[$i]->{'currency'}) {
		push @loop_pricescurrency, { currency => "<option selected value=\"$currencies->[$i]->{'currency'}\">$currencies->[$i]->{'currency'}</option>" };
	} else {
		push @loop_pricescurrency, { currency => "<option value=\"$currencies->[$i]->{'currency'}\">$currencies->[$i]->{'currency'}</option>"};
	}
	if ($booksellers[0]->{'invoiceprice'} eq $currencies->[$i]->{'currency'}) {
		push @loop_invoicecurrency, { currency => "<option selected value=\"$currencies->[$i]->{'currency'}\">$currencies->[$i]->{'currency'}</option>"};
	} else {
		push @loop_invoicecurrency, { currency => "<option value=\"$currencies->[$i]->{'currency'}\">$currencies->[$i]->{'currency'}</option>"};
	}
}
$template->param(id => $id,
					name => $booksellers[0]->{'name'},
					postal =>$booksellers[0]->{'postal'},
					address1 => $booksellers[0]->{'address1'},
					address2 => $booksellers[0]->{'address2'},
					address3 => $booksellers[0]->{'address3'},
					address4 => $booksellers[0]->{'address4'},
					phone =>$booksellers[0]->{'phone'},
					fax => $booksellers[0]->{'fax'},
					url => $booksellers[0]->{'url'},
					contact => $booksellers[0]->{'contact'},
					contpos => $booksellers[0]->{'contpos'},
					contphone => $booksellers[0]->{'contphone'},
					contaltphone => $booksellers[0]->{'contaltphone'},
					contfax => $booksellers[0]->{'contfax'},
					contemail => $booksellers[0]->{'contemail'},
					contnotes => $booksellers[0]->{'contnotes'},
					active => $booksellers[0]->{'active'},
					specialty => $booksellers[0]->{'specialty'},
					gstreg => $booksellers[0]->{'gstreg'},
					listincgst => $booksellers[0]->{'listincgst'},
					invoiceincgst => $booksellers[0]->{'invoiceincgst'},
					discount => $booksellers[0]->{'discount'},
					loop_pricescurrency => \@loop_pricescurrency,
					loop_invoicecurrency => \@loop_invoicecurrency,);

output_html_with_http_headers $query, $cookie, $template->output;
