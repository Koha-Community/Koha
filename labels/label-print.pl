#!/usr/bin/perl
#
# Copyright 2009 Foundations Bible College.
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

use CGI;
use HTML::Template::Pro;
use Data::Dumper;

use C4::Auth qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);
use C4::Labels::Lib 1.000000 qw(get_all_templates get_all_layouts get_label_output_formats);

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/label-print.tmpl",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $op = $cgi->param('op') || 'none';
my @select_labels = $cgi->param('label_id') if $cgi->param('label_id');   # this will handle individual label printing
my @batch_ids = $cgi->param('batch_id') if $cgi->param('batch_id');
my $layout_id = $cgi->param('layout_id') || undef; 
my $template_id = $cgi->param('template_id') || undef; 
my $start_label = $cgi->param('start_label') || 1; 
my $output_format = $cgi->param('output_format') || 'pdf';
my $layouts = undef;
my $templates = undef;
my $label_output_formats = undef;
my @batches = ();
my $multi_batch_count = scalar(@batch_ids);

if ($op eq 'export') {
    foreach my $batch_id (@batch_ids) {
       push (@batches, {create_script   => ($output_format eq 'pdf' ? 'label-create-pdf.pl' : 'label-create-csv.pl'),
                        batch_id        => $batch_id,
                        template_id     => $template_id,
                        layout_id       => $layout_id,
                        start_label     => $start_label,
                        });
    }
    $template->param(
                    batches     => \@batches,
                    );
}
elsif ($op eq 'none') {
    # setup select menus for selecting layout and template for this run...
    @batch_ids = grep{$_ = {batch_id => $_}} @batch_ids;
    $templates = get_all_templates(field_list => 'template_id, template_code');
    $layouts = get_all_layouts(field_list => 'layout_id, layout_name');
    $label_output_formats = get_label_output_formats();
    $template->param(
                    batch_ids                   => \@batch_ids,
                    templates                   => $templates,
                    layouts                     => $layouts,
                    label_output_formats        => $label_output_formats,
                    multi_batch_count           => $multi_batch_count,
                    );
}
output_html_with_http_headers $cgi, $cookie, $template->output;
