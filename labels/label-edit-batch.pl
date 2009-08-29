#!/usr/bin/perl
#
# Copyright 2006 Katipo Communications.
# Parts Copyright 2009 Foundations Bible College.
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

use strict;
use warnings;
use vars qw($debug);

use Sys::Syslog qw(syslog);
use Switch qw(Perl6);
use CGI;
use HTML::Template::Pro;
use Data::Dumper;
use JSON;

use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Branch qw(get_branch_code_from_name);
use C4::Debug;
use C4::Labels::Lib 1.000000 qw(get_label_summary html_table);
use C4::Labels::Batch 1.000000;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/label-edit-batch.tmpl",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);
my $err = 0;
my $errstr = undef;
my $db_rows = {};
my $batch = undef;
my $display_columns = [ {_label_number  => {label => 'Label Number', link_field => 0}},
                        {_summary       => {label => 'Summary', link_field => 0}},
                        {_item_type     => {label => 'Item Type', link_field => 0}},
                        {_barcode       => {label => 'Barcode', link_field => 0}},
                        {select         => {label => 'Select', value => '_label_id'}},
                      ];
my $op = $cgi->param('op') || undef;
my $label_id = $cgi->param('label_id') || undef;
my $batch_id = $cgi->param('element_id') || $cgi->param('batch_id') || undef;
my @item_numbers = $cgi->param('item_number') if $cgi->param('item_number');
my $branch_code = get_branch_code_from_name($template->param('LoginBranchname'));

if ($op eq 'remove') {
    $batch = C4::Labels::Batch->retrieve(batch_id => $batch_id);
    $err = $batch->remove_item($label_id);
    $errstr = "item $label_id was not removed." if $err;
}
elsif ($op eq 'delete') {
    $err = C4::Labels::Batch::delete(batch_id => $batch_id, branch_code => $branch_code);
    $errstr = "batch $batch_id was not deleted." if $err;
}
elsif ($op eq 'add') {
    $batch = C4::Labels::Batch->retrieve(batch_id => $batch_id);
    $batch = C4::Labels::Batch->new(branch_code => $branch_code) if $batch == -2;
    foreach my $item_number (@item_numbers) {
        $err = $batch->add_item($item_number);
    }
    $errstr = "item(s) not added to batch $batch_id." if $err;
}
elsif ($op eq 'new') {
    $batch = C4::Labels::Batch->new(branch_code => $branch_code);
    $batch_id = $batch->get_attr('batch_id');
}
else { # display batch
    $batch = C4::Labels::Batch->retrieve(batch_id => $batch_id);
}

my $items = $batch->get_attr('items');
$db_rows = get_label_summary(items => $items, batch_id => $batch_id);

my $table = html_table($display_columns, $db_rows);

$template->param(   err         => $err,
                    errstr      => $errstr,
                ) if ($err ne 0);
$template->param(
                op              => $op,
                batch_id        => $batch_id,
                table_loop      => $table,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
