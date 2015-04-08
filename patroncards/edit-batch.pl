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
use autouse 'Data::Dumper' => qw(Dumper);

use C4::Auth qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);
use C4::Creators;
use C4::Patroncards;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "patroncards/edit-batch.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $err = 0;
my $duplicate_count = undef;
my $duplicate_message = undef;
my $db_rows = {};
my $batch = undef;
my $display_columns = [ {_card_number   => {label => 'Card Number', link_field => 0}},
                        {_summary       => {label => 'Summary', link_field => 0}},
                        {borrowernumber => {label => 'Borrower Number', link_field => 0}},
                        {select         => {label => 'Select', value => '_label_id'}},
                      ];
my $op = $cgi->param('op') || 'new';
my $batch_id = $cgi->param('element_id') || $cgi->param('batch_id') || undef;
my @label_ids = $cgi->param('label_id') if $cgi->param('label_id');
my @item_numbers = $cgi->param('item_number') if $cgi->param('item_number');
my @borrower_numbers = $cgi->param('borrower_number') if $cgi->param('borrower_number');
my $errstr = $cgi->param('error') || '';

my $branch_code = C4::Context->userenv->{'branch'};

if ($op eq 'remove') {
    $batch = C4::Patroncards::Batch->retrieve(batch_id => $batch_id);
    foreach my $label_id (@label_ids) {
    $err = $batch->remove_item($label_id);
    }
    if ($err) {
        print $cgi->redirect("edit-batch.pl?op=edit&batch_id=$batch_id&error=403"); # this allows us to avoid problems with the user hitting their refresh button
        exit;
    }
}
elsif ($op eq 'delete') {
    $err = C4::Creators::Batch::delete(batch_id => $batch_id, branch_code => $branch_code);
    if ($err) {
        print $cgi->redirect("edit-batch.pl?op=edit&batch_id=$batch_id&error=404");
        exit;
    }
}
elsif ($op eq 'add') {
    $batch = C4::Patroncards::Batch->retrieve(batch_id => $batch_id);
    $batch = C4::Patroncards::Batch->new(branch_code => $branch_code) if $batch == -2;
    if ($branch_code){
        foreach my $borrower_number (@borrower_numbers) {
            $err = $batch->add_item($borrower_number);
        }
        if ($err) {
            print $cgi->redirect("edit-batch.pl?op=edit&batch_id=$batch_id&error=401");
            exit;
        }
    }
    else {
        print $cgi->redirect("edit-batch.pl?op=edit&batch_id=$batch_id&error=402");
        exit;
    }
}
elsif ($op eq 'de_duplicate') {
    $batch = C4::Patroncards::Batch->retrieve(batch_id => $batch_id);
    $duplicate_count = $batch->remove_duplicates();
    $duplicate_message = 1 if $duplicate_count != -1;
    if ($duplicate_count == -1) {
        print $cgi->redirect("edit-batch.pl?op=edit&batch_id=$batch_id&error=405");
        exit;
    }
}
elsif ($op eq 'edit') {
    $batch = C4::Patroncards::Batch->retrieve(batch_id => $batch_id);
}
elsif ($op eq 'new') {
    if ($branch_code eq '') {
        warn sprintf('Batch edit interface called with an invalid/non-existent branch code: %s',$branch_code ? $branch_code : 'NULL');
        print $cgi->redirect("manage.pl?card_element=batch&error=203");
        exit;
    }
    $batch = C4::Patroncards::Batch->new(branch_code => $branch_code);
    $batch_id = $batch->get_attr('batch_id');
}
else {
    warn sprintf('Batch edit interface called an unsupported operation: %s',$op);
    print $cgi->redirect("manage.pl?card_element=batch&error=202");
    exit;
}

my $items = $batch->get_attr('items');
$db_rows = get_card_summary(items => $items, batch_id => $batch_id);

my $table = html_table($display_columns, $db_rows);

$template->param(
                op                      => $op,
                batch_id                => $batch_id,
                table_loop              => $table,
                duplicate_message       => $duplicate_message,
                duplicate_count         => $duplicate_count,
                error                   => $errstr,
                );

output_html_with_http_headers $cgi, $cookie, $template->output;
