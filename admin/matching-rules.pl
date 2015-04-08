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
use warnings;

use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Koha;
use C4::Matcher;

my $script_name = "/cgi-bin/koha/admin/matching-rules.pl";

our $input = new CGI;
my $op = $input->param('op') || '';


my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/matching-rules.tt",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {parameters => 'parameters_remaining_permissions'},
                 debug => 1,
                 });

$template->param(script_name => $script_name);

my $matcher_id = $input->param("matcher_id");

$template->param(max_matchpoint => 0);
$template->param(max_matchcheck => 0);
my $display_list = 0;
if ($op eq "edit_matching_rule") {
    edit_matching_rule_form($template, $matcher_id);
} elsif ($op eq "edit_matching_rule_confirmed") {
    add_update_matching_rule($template, $matcher_id);
    $display_list = 1;
} elsif ($op eq "add_matching_rule") {
    add_matching_rule_form($template);
} elsif ($op eq "add_matching_rule_confirmed") {
    add_update_matching_rule($template, $matcher_id);
    $display_list = 1;
} elsif ($op eq "delete_matching_rule") {
    delete_matching_rule_form($template, $matcher_id);
} elsif ($op eq "delete_matching_rule_confirmed") {
    delete_matching_rule($template, $matcher_id);
    $display_list = 1;
} else {
    $display_list = 1;
}

if ($display_list) {
    matching_rule_list($template);
}

output_html_with_http_headers $input, $cookie, $template->output;

exit 0;

sub add_matching_rule_form {
    my $template = shift;

    $template->param(
        matching_rule_form => 1,
        confirm_op => 'add_matching_rule_confirmed',
        max_matchpoint => 1,
        max_matchcheck => 1
    );

}

sub add_update_matching_rule {
    my $template = shift;
    my $matcher_id = shift;
    my $record_type = $input->param('record_type') || 'biblio';

    # do parsing
    my $matcher = C4::Matcher->new($record_type, 1000);
    $matcher->code($input->param('code'));
    $matcher->description($input->param('description'));
    $matcher->threshold($input->param('threshold'));

    # matchpoints
    my @mp_nums = sort map { /^mp_(\d+)_search_index/ ? int($1): () } $input->param;
    foreach my $mp_num (@mp_nums) {
        my $index = $input->param("mp_${mp_num}_search_index");
        my $score = $input->param("mp_${mp_num}_score");
        # components
        my $components = [];
        my @comp_nums = sort map { /^mp_${mp_num}_c_(\d+)_tag/ ? int($1): () } $input->param;
        foreach my $comp_num (@comp_nums) {
            my $component = {};
            $component->{'tag'} = $input->param("mp_${mp_num}_c_${comp_num}_tag");
            $component->{'subfields'} = $input->param("mp_${mp_num}_c_${comp_num}_subfields");
            $component->{'offset'} = $input->param("mp_${mp_num}_c_${comp_num}_offset");
            $component->{'length'} = $input->param("mp_${mp_num}_c_${comp_num}_length");
            # norms
            $component->{'norms'} = [];
            my @norm_nums = sort map { /^mp_${mp_num}_c_${comp_num}_n_(\d+)_norm/ ? int($1): () } $input->param;
            foreach my $norm_num (@norm_nums) {
                push @{ $component->{'norms'} }, $input->param("mp_${mp_num}_c_${comp_num}_n_${norm_num}_norm");
            }
            push @$components, $component;
        }
        $matcher->add_matchpoint($index, $score, $components);
    }

    # match checks
    my @mc_nums = sort map { /^mc_(\d+)_id/ ? int($1): () } $input->param;
    foreach my $mc_num (@mc_nums) {
        # source components
        my $src_components = [];
        my @src_comp_nums = sort map { /^mc_${mc_num}_src_c_(\d+)_tag/ ? int($1): () } $input->param;
        foreach my $comp_num (@src_comp_nums) {
            my $component = {};
            $component->{'tag'} = $input->param("mc_${mc_num}_src_c_${comp_num}_tag");
            $component->{'subfields'} = $input->param("mc_${mc_num}_src_c_${comp_num}_subfields");
            $component->{'offset'} = $input->param("mc_${mc_num}_src_c_${comp_num}_offset");
            $component->{'length'} = $input->param("mc_${mc_num}_src_c_${comp_num}_length");
            # norms
            $component->{'norms'} = [];
            my @norm_nums = sort map { /^mc_${mc_num}_src_c_${comp_num}_n_(\d+)_norm/ ? int($1): () } $input->param;
            foreach my $norm_num (@norm_nums) {
                push @{ $component->{'norms'} }, $input->param("mc_${mc_num}_src_c_${comp_num}_n_${norm_num}_norm");
            }
            push @$src_components, $component;
        }
        # target components
        my $tgt_components = [];
        my @tgt_comp_nums = sort map { /^mc_${mc_num}_tgt_c_(\d+)_tag/ ? int($1): () } $input->param;
        foreach my $comp_num (@tgt_comp_nums) {
            my $component = {};
            $component->{'tag'} = $input->param("mc_${mc_num}_tgt_c_${comp_num}_tag");
            $component->{'subfields'} = $input->param("mc_${mc_num}_tgt_c_${comp_num}_subfields");
            $component->{'offset'} = $input->param("mc_${mc_num}_tgt_c_${comp_num}_offset");
            $component->{'length'} = $input->param("mc_${mc_num}_tgt_c_${comp_num}_length");
            # norms
            $component->{'norms'} = [];
            my @norm_nums = sort map { /^mc_${mc_num}_tgt_c_${comp_num}_n_(\d+)_norm/ ? int($1): () } $input->param;
            foreach my $norm_num (@norm_nums) {
                push @{ $component->{'norms'} }, $input->param("mc_${mc_num}_tgt_c_${comp_num}_n_${norm_num}_norm");
            }
            push @$tgt_components, $component;
        }
        $matcher->add_required_check($src_components, $tgt_components);
    }
    
    if (defined $matcher_id and $matcher_id =~ /^\d+/) {
        $matcher->_id($matcher_id);
        $template->param(edited_matching_rule => $matcher->code());
    } else {
        $template->param(added_matching_rule => $matcher->code());
    }
    $matcher_id = $matcher->store();
}

sub delete_matching_rule_form {
    my $template = shift;
    my $matcher_id = shift;

    my $matcher = C4::Matcher->fetch($matcher_id);
    $template->param(
        delete_matching_rule_form => 1,
        confirm_op => "delete_matching_rule_confirmed",
        matcher_id => $matcher_id,
        code => $matcher->code(),
        description => $matcher->description(),
    );
}

sub delete_matching_rule {
    my $template = shift;
    my $matcher_id = shift;

    my $matcher = C4::Matcher->fetch($matcher_id);
    $template->param(deleted_matching_rule => $matcher->code(),
                    );
    C4::Matcher->delete($matcher_id);
}

sub edit_matching_rule_form {
    my $template = shift;
    my $matcher_id = shift;

    my $matcher = C4::Matcher->fetch($matcher_id);

    $template->{VARS}->{'matcher_id'} = $matcher_id;
    $template->{VARS}->{'code'} = $matcher->code();
    $template->{VARS}->{'description'} = $matcher->description();
    $template->{VARS}->{'threshold'} = $matcher->threshold();
    $template->{VARS}->{'record_type'} = $matcher->record_type();

    my $matcher_info = $matcher->dump();
    my @matchpoints = ();
    my $mp_num = 0;
    foreach my $matchpoint (@{ $matcher_info->{'matchpoints'} }) {
        $mp_num++;
        my @components = _parse_components($matchpoint->{'components'});
        push @matchpoints, { 
            mp_num => $mp_num, 
            index => $matchpoint->{'index'}, 
            score => $matchpoint->{'score'},
            components => \@components
        };        
    }
    $template->param(matchpoints => \@matchpoints);

    my $mc_num = 0;
    my @matchchecks = ();
    foreach my $matchcheck (@{ $matcher_info->{'matchchecks'} }) {
        $mc_num++;
        my @src_components = _parse_components($matchcheck->{'source_matchpoint'}->{'components'});
        my @tgt_components = _parse_components($matchcheck->{'target_matchpoint'}->{'components'});
        push @matchchecks, {
            mc_num => $mc_num,
            src_components => \@src_components,
            tgt_components => \@tgt_components
        };
    }
    $template->param(matchchecks => \@matchchecks);

    $template->param(
        matching_rule_form => 1,
        edit_matching_rule => 1,
        confirm_op => 'edit_matching_rule_confirmed',
        max_matchpoint => $mp_num,
        max_matchcheck => $mc_num
    );

}

sub _parse_components {
    my $components_ref = shift;
    my @components = ();

    my $comp_num = 0;
    foreach my $component (@{ $components_ref  }) {
        $comp_num++;
        my $norm_num = 0;
        my @norms;
        foreach my $norm (@{ $component->{'norms'} }) {
            $norm_num++;
            push @norms, { norm_num => $norm_num, norm => $norm };
        }
        push @components, {
            comp_num => $comp_num,
            tag => $component->{'tag'},
            subfields => join("", sort keys %{ $component->{'subfields'} }),
            offset => $component->{'offset'},
            'length' => $component->{'length'},
            norms => \@norms
        };
    }

    return @components;
}

sub matching_rule_list {
    my $template = shift;
    
    my @matching_rules = C4::Matcher::GetMatcherList();
    $template->param(available_matching_rules => \@matching_rules);
    $template->param(display_list => 1);
}
