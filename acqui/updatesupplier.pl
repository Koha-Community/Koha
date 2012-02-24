#!/usr/bin/perl

#script to show suppliers and orders
#written by chris@katipo.co.nz 23/2/2000


# Copyright 2000-2002 Katipo Communications
# Copyright 2008-2009 BibLibre SARL
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

updatesupplier.pl

=head1 DESCRIPTION

this script allow to update or create (if id == 0)
a supplier. This script is called from acqui/supplier.pl.

=head1 CGI PARAMETERS

All informations regarding this supplier are listed on input parameter.
Here is the list :

supplier, id, company, company_postal, physical, company_phone,
physical, company_phone, company_fax, website, company_contact_name,
company_contact_position, contact_phone, contact_phone_2, contact_fax,
company_email, contact_notes, notes, status, publishers_imprints,
list_currency, gst, list_gst, invoice_gst, discount, gstrate.

=cut

use strict;
#use warnings; FIXME - Bug 2505
use C4::Context;
use C4::Auth;

use C4::Bookseller qw( ModBookseller AddBookseller );
use C4::Biblio;
use C4::Output;
use CGI;

my $input=new CGI;
my ($template, $loggedinuser, $cookie) = get_template_and_user(
	{   template_name   => "",
		query           => $input,
		type            => "intranet",
		authnotrequired => 0,
		flagsrequired   => { acquisition => 'vendors_manage' },
		debug           => 1,
	}
);

#print $input->header();
my $booksellerid=$input->param('booksellerid');
#print startpage;
my %data;
$data{'id'}=$booksellerid;

$data{'name'}=$input->param('company');
$data{'postal'}=$input->param('company_postal');
my $address=$input->param('physical');
my @addresses=split('\n',$address);
$data{'address1'}=$addresses[0];
$data{'address2'}=$addresses[1];
$data{'address3'}=$addresses[2];
$data{'address4'}=$addresses[3];
$data{'phone'}=$input->param('company_phone');
$data{'accountnumber'}=$input->param('accountnumber');
$data{'fax'}=$input->param('company_fax');
$data{'url'}=$input->param('website');
$data{'contact'}=$input->param('company_contact_name');
$data{'contpos'}=$input->param('company_contact_position');
$data{'contphone'}=$input->param('contact_phone');
$data{'contaltphone'}=$input->param('contact_phone_2');
$data{'contfax'}=$input->param('contact_fax');
$data{'contemail'}=$input->param('company_email');
$data{'contnotes'}=$input->param('contact_notes');
# warn "".$data{'contnotes'};
$data{'notes'}=$input->param('notes');
$data{'active'}=$input->param('status');

$data{'listprice'}=$input->param('list_currency');
$data{'invoiceprice'}=$input->param('invoice_currency');
$data{'gstreg'}=$input->param('gst');
$data{'listincgst'}=$input->param('list_gst');
$data{'invoiceincgst'}=$input->param('invoice_gst');
#have to transform this into fraction so it's easier to use
$data{'gstrate'} = $input->param('gstrate');
$data{'discount'} = $input->param('discount');
$data{deliverytime} = $input->param('deliverytime');
$data{'active'}=$input->param('status');
if($data{'name'}) {
	if ($data{'id'}){
	    ModBookseller(\%data);
	} else {
	    $data{id}=AddBookseller(\%data);
	}
#redirect to booksellers.pl
print $input->redirect("booksellers.pl?booksellerid=".$data{id});
} else {
print $input->redirect("supplier.pl?op=enter"); # fail silently.
}
