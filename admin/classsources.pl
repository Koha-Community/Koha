#!/usr/bin/perl
#
# Copyright 2007 LibLime
# Copyright 2018 Koha Development Team
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

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::ClassSortRoutine qw( GetSortRoutineNames );
use C4::ClassSplitRoutine qw( GetSplitRoutineNames );
use Koha::ClassSources;
use Koha::ClassSortRules;
use Koha::ClassSplitRules;

my $script_name = "/cgi-bin/koha/admin/classsources.pl";

my $input            = CGI->new;
my $op               = $input->param('op') || 'list';
my $cn_source        = $input->param('cn_source');
my $class_sort_rule  = $input->param('class_sort_rule');
my $class_split_rule = $input->param('class_split_rule');
my $sort_routine     = $input->param('sort_routine');
my $split_routine    = $input->param('split_routine');
my @split_regex      = $input->multi_param('split_regex');
my $description      = $input->param('description');
my $used             = $input->param('used');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/classsources.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { parameters => 'manage_classifications' },
    }
);

my @messages;
$template->param( script_name => $script_name );

if ( $op eq "add_source" ) {
    my $class_source =
      $cn_source ? Koha::ClassSources->find($cn_source) : undef;
    $template->param(
        class_source => $class_source,
        sort_rules   => Koha::ClassSortRules->search,
        split_rules  => Koha::ClassSplitRules->search,
    );
}
elsif ( $op eq "add_source_validate" ) {
    my $class_source = Koha::ClassSources->find($cn_source);
    if ($class_source) {
        $class_source->set(
            {
                description      => $description,
                used             => ( $used eq 'used' ? 1 : 0 ),
                class_sort_rule  => $class_sort_rule,
                class_split_rule => $class_split_rule,
            }
        );
        eval { $class_source->store; };
        if ($@) {
            push @messages,
              { type => 'error', code => 'error_on_update_source' };
        }
        else {
            push @messages,
              { type => 'message', code => 'success_on_update_source' };
        }

    }
    else {
        $class_source = Koha::ClassSource->new(
            {
                cn_source        => $cn_source,
                description      => $description,
                used             => ( $used eq 'used' ? 1 : 0 ),
                class_sort_rule  => $class_sort_rule,
                class_split_rule => $class_split_rule,
            }
        );
        eval { $class_source->store; };
        if ($@) {
            push @messages,
              { type => 'error', code => 'error_on_insert_source' };
        }
        else {
            push @messages,
              { type => 'message', code => 'success_on_insert_source' };
        }
    }

    $op = 'list';
}
elsif ( $op eq "delete_source_confirmed" ) {
    my $class_source = Koha::ClassSources->find($cn_source);
    my $deleted = eval { $class_source->delete };
    if ( $@ or not $deleted ) {
        push @messages, { type => 'error', code => 'error_on_delete_source' };
    }
    else {
        push @messages,
          { type => 'message', code => 'success_on_delete_source' };
    }

    $op = 'list';
}
elsif ( $op eq "add_sort_rule" ) {
    my $sort_rule =
      $class_sort_rule ? Koha::ClassSortRules->find($class_sort_rule) : undef;
    $template->param(
        sort_rule     => $sort_rule,
        sort_routines => get_class_sort_routines(),
    );
}
elsif ( $op eq "add_sort_rule_validate" ) {
    my $sort_rule = Koha::ClassSortRules->find($class_sort_rule);
    if ($sort_rule) {
        $sort_rule->set(
            { description => $description, sort_routine => $sort_routine } );
        eval { $sort_rule->store; };
        if ($@) {
            push @messages,
              { type => 'error', code => 'error_on_update_sort_rule' };
        }
        else {
            push @messages,
              { type => 'message', code => 'success_on_update_sort_rule' };
        }

    }
    else {
        $sort_rule = Koha::ClassSortRule->new(
            {
                class_sort_rule => $class_sort_rule,
                description     => $description,
                sort_routine    => $sort_routine,
            }
        );
        eval { $sort_rule->store; };
        if ($@) {
            push @messages,
              { type => 'error', code => 'error_on_insert_sort_rule' };
        }
        else {
            push @messages,
              { type => 'message', code => 'success_on_insert_sort_rule' };
        }
    }
    $op = 'list';
}
elsif ( $op eq "delete_sort_rule" ) {
    my $sort_rule = Koha::ClassSortRules->find($class_sort_rule);
    my $deleted = eval { $sort_rule->delete };
    if ( $@ or not $deleted ) {
        push @messages,
          { type => 'error', code => 'error_on_delete_sort_rule' };
    }
    else {
        push @messages,
          { type => 'message', code => 'success_on_delete_sort_rule' };
    }
    $op = 'list';
}
elsif ( $op eq "add_split_rule" ) {
    my $split_rule =
      $class_split_rule
      ? Koha::ClassSplitRules->find($class_split_rule)
      : undef;
    $template->param(
        split_rule     => $split_rule,
        split_routines => get_class_split_routines(),
    );
}
elsif ( $op eq "add_split_rule_validate" ) {
    my $split_rule = Koha::ClassSplitRules->find($class_split_rule);

    @split_regex =  grep {!/^$/} @split_regex; # Remove empty
    if ($split_rule) {
        $split_rule->set(
            {
                description   => $description,
                split_routine => $split_routine,
            }
        );
        eval {
            $split_rule->regexs(\@split_regex)
                if $split_routine eq 'RegEx';
            $split_rule->store;
        };
        if ($@) {
            push @messages,
              { type => 'error', code => 'error_on_update_split_rule' };
        }
        else {
            push @messages,
              { type => 'message', code => 'success_on_update_split_rule' };
        }

    }
    else {
        $split_rule = Koha::ClassSplitRule->new(
            {
                class_split_rule => $class_split_rule,
                description      => $description,
                split_routine    => $split_routine,
                regexs           => \@split_regex,
            }
        );
        eval { $split_rule->store; };
        if ($@) {
            warn $@;
            push @messages,
              { type => 'error', code => 'error_on_insert_split_rule' };
        }
        else {
            push @messages,
              { type => 'message', code => 'success_on_insert_split_rule' };
        }
    }
    $op = 'list';
}
elsif ( $op eq "delete_split_rule" ) {
    my $split_rule = Koha::ClassSplitRules->find($class_split_rule);
    my $deleted = eval { $split_rule->delete };
    if ( $@ or not $deleted ) {
        push @messages,
          { type => 'error', code => 'error_on_delete_split_rule' };
    }
    else {
        push @messages,
          { type => 'message', code => 'success_on_delete_split_rule' };
    }
    $op = 'list';
}

if ( $op eq 'list' ) {
    my $class_sources = Koha::ClassSources->search;
    my $sort_rules    = Koha::ClassSortRules->search;
    my $split_rules   = Koha::ClassSplitRules->search;
    $template->param(
        class_sources => $class_sources,
        sort_rules    => $sort_rules,
        split_rules   => $split_rules,
    );
}

$template->param( op => $op, messages => \@messages, );
output_html_with_http_headers $input, $cookie, $template->output;

exit 0;

sub get_class_sort_routines {
    my @sort_routines = GetSortRoutineNames();
    return \@sort_routines;
}

sub get_class_split_routines {
    my @split_routines = GetSplitRoutineNames();
    return \@split_routines;
}
