#!/usr/bin/perl

#script to show suppliers and orders
#written by chris@katipo.co.nz 23/2/2000

use C4::Acquisitions;
use C4::Output;
use CGI;
use strict;

my $input=new CGI;
#print $input->header();
my $supplier=$input->param('supplier');
#print startpage;
my %data;
$data{'id'}=$input->param('id');

$data{'name'}=$input->param('company');
$data{'name'}=~ s/\'/\\\'/g;
$data{'postal'}=$input->param('company_postal');
my $address=$input->param('physical');
my @addresses=split('\n',$address);
$data{'address1'}=$addresses[0];
$data{'address2'}=$addresses[1];
$data{'address3'}=$addresses[2];
$data{'address4'}=$addresses[3];
$data{'phone'}=$input->param('company_phone');
$data{'fax'}=$input->param('company_fax');
$data{'url'}=$input->param('website');
$data{'contact'}=$input->param('company_contact_name');
$data{'contpos'}=$input->param('company_contact_position');
$data{'contphone'}=$input->param('contact_phone');
$data{'contaltphone'}=$input->param('contact_phone_2');
$data{'contfax'}=$input->param('contact_fax');
$data{'contemail'}=$input->param('company_email');
$data{'contnotes'}=$input->param('notes');
$data{'active'}=$input->param('status');
$data{'specialty'}=$input->param('publishers_imprints');
$data{'listprice'}=$input->param('list_currency');
$data{'invoiceprice'}=$input->param('invoice_currency');
$data{'gstreg'}=$input->param('gst');
$data{'listincgst'}=$input->param('list_gst');
$data{'invoiceincgst'}=$input->param('invoice_gst');
$data{'discount'}=$input->param('discount');
my $id=$input->param('id');
if ($data{'id'} != 0){
  updatesup(\%data);
} else {
  $id=insertsup(\%data);
}
#print startmenu('acquisitions');
#my ($count,@suppliers)=bookseller($supplier);

#print $input->dump;


#print endmenu('acquisitions');

#print endpage;

print $input->redirect("order.pl?supplier=$id");
