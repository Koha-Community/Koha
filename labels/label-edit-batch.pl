#!/usr/bin/perl
#
# Copyright 2006 Katipo Communications.
# Parts Copyright 2009 Foundations Bible College.
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;
use vars qw($debug);

use CGI;

use C4::Auth qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);
use C4::Items qw(GetItemnumberFromBarcode);
use C4::Creators;
use C4::Labels;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/label-edit-batch.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $err = 0;
my $errstr = undef;
my $duplicate_count = undef;
my $duplicate_message = undef;
my $db_rows = {};
my $batch = undef;
my $display_columns = [ {_label_number  => {label => 'Label Number', link_field => 0}},
                        {_summary       => {label => 'Summary', link_field => 0}},
                        {_item_type     => {label => 'Item Type', link_field => 0}},
                        {_barcode       => {label => 'Barcode', link_field => 0}},
                        {select         => {label => 'Select', value => '_label_id'}},
                      ];
my $op = $cgi->param('op') || 'edit';
my @label_ids;
my @item_numbers;
my $barcode;
my $batch_id = $cgi->param('element_id') || $cgi->param('batch_id') || undef;
@label_ids = $cgi->param('label_id') if $cgi->param('label_id');
@item_numbers = $cgi->param('item_number') if $cgi->param('item_number');
$barcode = $cgi->param('barcode') if $cgi->param('barcode');

my $branch_code = C4::Context->userenv->{'branch'};

if ($op eq 'remove') {
    $batch = C4::Labels::Batch->retrieve(batch_id => $batch_id);
    foreach my $label_id (@label_ids) {
    $err = $batch->remove_item($label_id);
    }
    $errstr = "item(s) not removed from batch $batch_id." if $err;
#    Something like this would be nice to avoid problems with the browser's 'refresh' button, but it needs an error handling mechanism...
#    print $cgi->redirect("label-edit-batch.pl?op=edit&batch_id=$batch_id");
#    exit;
}
elsif ($op eq 'delete') {
    $err = C4::Labels::Batch::delete(batch_id => $batch_id, branch_code => $branch_code);
    $errstr = "batch $batch_id was not deleted." if $err;
}
elsif ($op eq 'add') {
    if ($barcode) {
        my @barcodes = split /\n/, $barcode; # $barcode is effectively passed in as a <cr> separated list
        foreach my $number (@barcodes) {
            $number =~ s/\r$//; # strip any naughty return chars
            if (my $item_number = GetItemnumberFromBarcode($number)) {  # we must test in case an invalid barcode is passed in; we effectively disgard them atm
                push @item_numbers, $item_number;
            }
        }
    }
    $batch = C4::Labels::Batch->retrieve(batch_id => $batch_id);
    $batch = C4::Labels::Batch->new(branch_code => $branch_code) if $batch == -2;
    if ($branch_code){
        foreach my $item_number (@item_numbers) {
            $err = $batch->add_item($item_number);
        }
        $errstr = "item(s) not added to batch $batch_id." if $err;
    }
    else {
        $err = 1;
        $errstr = "items(s) not added, the error was: Branch is not set, you please set your branch before adding items to a batch";
    }
}
elsif ($op eq 'new') {
    $batch = C4::Labels::Batch->new(branch_code => $branch_code);
    $batch_id = $batch->get_attr('batch_id');
}
elsif ($op eq 'de_duplicate') {
    $batch = C4::Labels::Batch->retrieve(batch_id => $batch_id);
    $duplicate_count = $batch->remove_duplicates();
    $duplicate_message = 1 if $duplicate_count != -1;
    $errstr = "batch $batch_id not fully de-duplicated." if $duplicate_count == -1;
}
else { # edit
    $batch = C4::Labels::Batch->retrieve(batch_id => $batch_id);
}

my $items = $batch->get_attr('items');
$db_rows = get_label_summary(items => $items, batch_id => $batch_id);

my $table = html_table($display_columns, $db_rows);

$template->param(
                err         => $err,
                errstr      => $errstr,
                ) if ($err ne 0);

$template->param(
                op                      => $op,
                batch_id                => $batch_id,
                table_loop              => $table,
                duplicate_message       => $duplicate_message,
                duplicate_count         => $duplicate_count,
                );

output_html_with_http_headers $cgi, $cookie, $template->output;
