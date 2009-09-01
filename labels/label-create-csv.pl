#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use Sys::Syslog qw(syslog);
use Text::CSV_XS;
use Data::Dumper;

use C4::Debug;
use C4::Labels::Batch 1.000000;
use C4::Labels::Template 1.000000;
use C4::Labels::Layout 1.000000;
use C4::Labels::PDF 1.000000;
use C4::Labels::Label 1.000000;

=head

=cut

my $cgi = new CGI;

my $batch_id    = $cgi->param('batch_id') if $cgi->param('batch_id');
my $template_id = $cgi->param('template_id') || undef;
my $layout_id   = $cgi->param('layout_id') || undef;
my @label_ids   = $cgi->param('label_id') if $cgi->param('label_id');
my @item_numbers  = $cgi->param('item_number') if $cgi->param('item_number');

my $items = undef;

my $csv_file = (@label_ids || @item_numbers ? "label_single_" . scalar(@label_ids || @item_numbers) : "label_batch_$batch_id");
print $cgi->header(-type        => 'application/vnd.sun.xml.calc',
                   -encoding    => 'utf-8',
                   -attachment  => "$csv_file.csv",
                    );


my $batch = C4::Labels::Batch->retrieve(batch_id => $batch_id);
my $template = C4::Labels::Template->retrieve(template_id => $template_id, profile_id => 1);
my $layout = C4::Labels::Layout->retrieve(layout_id => $layout_id);


if (@label_ids) {
    my $batch_items = $batch->get_attr('items');
    grep {
        my $label_id = $_;
        push(@{$items}, grep{$_->{'label_id'} == $label_id;} @{$batch_items});
    } @label_ids;
}
elsif (@item_numbers) {
    grep {
        push(@{$items}, {item_number => $_});
    } @item_numbers;
}
else {
    $items = $batch->get_attr('items');
}

my $csv = Text::CSV_XS->new();

CSV_ITEMS:
foreach my $item (@$items) {
    my $label = C4::Labels::Label->new(
                                    batch_id            => $batch_id,
                                    item_number         => $item->{'item_number'},
                                    format_string       => $layout->get_attr('format_string'),
                                      );
    my $csv_fields = $label->csv_data();
    if ($csv->combine(@$csv_fields)) {
        print $csv->string() . "\n";
    }
    else {
        syslog("LOG_ERR", "labels/label-create-csv.pl : Text::CSV_XS->combine() returned the following error: %s", $csv->error_input);
        next CSV_ITEMS;
    }
}

exit(1);

=head1 NAME

labels/label-create-csv.pl - A script for creating a csv export of labels and label batches in Koha

=head1 ABSTRACT

This script provides the means of producing a csv of labels for items either individually, in groups, or in batches from within Koha.

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=head1 COPYRIGHT

Copyright 2009 Foundations Bible College.

=head1 LICENSE

This file is part of Koha.
       
Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along with Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
Suite 330, Boston, MA  02111-1307 USA

=head1 DISCLAIMER OF WARRANTY

Koha is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

