#! /usr/bin/perl
#
# Copyright 2007 LibLime
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
#

use strict;
#use warnings; FIXME - Bug 2505
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Koha;
use C4::ClassSource;
use C4::ClassSortRoutine;

my $script_name = "/cgi-bin/koha/admin/classsources.pl";

my $input = new CGI;
my $op          = $input->param('op') || '';
my $source_code = $input->param('class_source');
my $rule_code   = $input->param('sort_rule');

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/classsources.tt",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {parameters => 'parameters_remaining_permissions'},
                 debug => 1,
                 });

$template->param(script_name => $script_name);
$template->param($op => 1) if $op;

my $display_lists = 0;
if ($op eq "add_source") {
    add_class_source_form($template);
} elsif ($op eq "add_source_confirmed") {
    add_class_source($template,
                     $source_code,
                     $input->param('description'),
                     $input->param('used') eq "used" ? 1 : 0,
                     $rule_code);
    $display_lists = 1;
} elsif ($op eq "delete_source") {
    delete_class_source_form($template);
} elsif ($op eq "delete_source_confirmed") {
    delete_class_source($template, $source_code);
    $display_lists = 1;
} elsif ($op eq "edit_source") {
    edit_class_source_form($template, $source_code);
} elsif ($op eq "edit_source_confirmed") {
    edit_class_source($template,
                     $source_code,
                     $input->param('description'),
                     $input->param('used') eq "used" ? 1 : 0,
                     $rule_code);
    $display_lists = 1;
} elsif ($op eq "add_sort_rule") {
    add_class_sort_rule_form($template);
} elsif ($op eq "add_sort_rule_confirmed") {
    add_class_sort_rule($template,
                        $rule_code,
                        $input->param('description'),
                        $input->param('sort_routine'));
    $display_lists = 1;
} elsif ($op eq "delete_sort_rule") {
    delete_sort_rule_form($template, $rule_code);
} elsif ($op eq "delete_sort_rule_confirmed") { 
    delete_sort_rule($template, $rule_code);
    $display_lists = 1;
} elsif ($op eq "edit_sort_rule") { 
    edit_class_sort_rule_form($template, $rule_code);
} elsif ($op eq "edit_sort_rule_confirmed") {
    edit_class_sort_rule($template,
                         $rule_code,
                         $input->param('description'),
                         $input->param('sort_routine'));
    $display_lists = 1;
} else {
    $display_lists = 1;
}

if ($display_lists) {
    $template->param(display_lists => 1);
    class_source_list($template);
    class_sort_rule_list($template);
}

output_html_with_http_headers $input, $cookie, $template->output;

exit 0;

sub add_class_source_form {
    my ($template) = @_;
    $template->param(
        class_source_form => 1,
        confirm_op => "add_source_confirmed",
        used => 0
    );
    get_sort_rule_codes($template, '');
}

sub add_class_source {
    my ($template, $source_code, $description, $used, $sort_rule) = @_;
    AddClassSource($source_code, $description, $used, $sort_rule);
    $template->param(added_source => $source_code);
}

sub edit_class_source_form {
    my ($template, $source_code) = @_;

    my $source = GetClassSource($source_code);
    $template->param(
        class_source_form => 1,
        edit_class_source => 1,
        class_source => $source_code,
        confirm_op => "edit_source_confirmed",
        description => $source->{'description'},
        used => $source->{'used'},
    );

    get_sort_rule_codes($template, $source->{'class_sort_rule'});
}

sub edit_class_source {
    my ($template, $source_code, $description, $used, $sort_rule) = @_;
    ModClassSource($source_code, $description, $used, $sort_rule);
    $template->param(edited_source => $source_code);
}


sub delete_class_source_form {
    my ($template) = @_;
    $template->param(
        delete_class_source_form => 1,
        confirm_op   => "delete_source_confirmed",
        class_source => $source_code,
    );
}

sub delete_class_source { 
    my ($template, $source_code) = @_;
    DelClassSource($source_code);
    $template->param(deleted_source => $source_code);
}

sub get_sort_rule_codes {
    my ($template, $current_rule) = @_;

    my $sort_rules = GetClassSortRules();

    my @sort_rules = ();
    foreach my $sort_rule (sort keys %$sort_rules) {
        my $sort_rule = $sort_rules->{$sort_rule};
        push @sort_rules, {
            rule        => $sort_rule->{'class_sort_rule'},
            description => $sort_rule->{'description'},
            selected    => $sort_rule->{'class_sort_rule'} eq $current_rule ? 1 : 0
        };
    }
    $template->param(rules_dropdown => \@sort_rules);
 
}

sub add_class_sort_rule_form {
    my ($template) = @_;
    $template->param(
        sort_rule_form => 1,
        confirm_op => "add_sort_rule_confirmed"
    );
    get_class_sort_routines($template, "");
}

sub add_class_sort_rule {
    my ($template, $rule_code, $description, $sort_routine) = @_;
    AddClassSortRule($rule_code, $description, $sort_routine);
    $template->param(added_rule => $rule_code);
}

sub delete_sort_rule_form {
    my ($template, $rule_code) = @_;

    my @sources = GetSourcesForSortRule($rule_code);
    if ($#sources == -1) {
        $template->param(
            delete_sort_rule_form => 1,
            confirm_op => "delete_sort_rule_confirmed",
            sort_rule  => $rule_code,
        );
    } else {
        $template->param(
            delete_sort_rule_impossible => 1,
            sort_rule => $rule_code
        );
    }
}

sub delete_sort_rule { 
    my ($template, $rule_code) = @_;
    DelClassSortRule($rule_code);
    $template->param(deleted_rule => $rule_code);
}

sub edit_class_sort_rule_form {
    my ($template, $rule_code) = @_;

    my $rule = GetClassSortRule($rule_code);
    $template->param(
        sort_rule_form => 1,
        edit_sort_rule => 1,
        confirm_op   => "edit_sort_rule_confirmed",
        sort_rule    => $rule_code,
        description  => $rule->{'description'},
        sort_routine => $rule->{'sort_routine'}
    );

    get_class_sort_routines($template, $rule->{'sort_routine'});

}

sub get_class_sort_routines {
    my ($template, $current_routine) = @_;

    my @sort_routines = GetSortRoutineNames();
    my @sort_form = ();

    foreach my $sort_routine (sort @sort_routines) {    
        push @sort_form, {
            routine  => $sort_routine,
            selected => $sort_routine eq $current_routine ? 1 : 0
        };
    }
    $template->param(routines_dropdown => \@sort_form);

}

sub edit_class_sort_rule {
    my ($template, $rule_code, $description, $sort_routine) = @_;
    ModClassSortRule($rule_code, $description, $sort_routine);
    $template->param(edited_rule => $rule_code);
} 

sub class_source_list {
    my ($template) = @_;
    my $sources = GetClassSources();

    my @sources = ();
    foreach my $cn_source (sort keys %$sources) {
        my $source = $sources->{$cn_source};
        push @sources, {
            code        => $source->{'cn_source'},
            description => $source->{'description'},
            used        => $source->{'used'},
            sortrule    => $source->{'class_sort_rule'}
        };
    }
    $template->param(class_sources => \@sources);
}

sub class_sort_rule_list {

    my ($template) = @_;
    my $sort_rules = GetClassSortRules();

    my @sort_rules = ();
    foreach my $sort_rule (sort keys %$sort_rules) {
        my $sort_rule = $sort_rules->{$sort_rule};
        push @sort_rules, {
            rule        => $sort_rule->{'class_sort_rule'},
            description => $sort_rule->{'description'},
            sort_routine    => $sort_rule->{'sort_routine'}
        }; 
    }
    $template->param(class_sort_rules => \@sort_rules);
}
