#!/usr/bin/perl

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

use Modern::Perl;

# standard or CPAN modules used
use CGI qw ( -utf8 );
use CGI::Cookie;
use MARC::File::USMARC;
use Try::Tiny;

# Koha modules used
use C4::Context;
use C4::Koha;
use C4::Auth;
use C4::AuthoritiesMarc;
use C4::Output;
use C4::Biblio;
use C4::ImportBatch;
use C4::Matcher;
use C4::BackgroundJob;
use C4::Labels::Batch;
use Koha::MarcMergeRules;
use Koha::MarcMergeRule;
use Koha::Patron::Categories; # TODO: Required? Try without use

my $script_name = "/cgi-bin/koha/admin/marc-merge-rules.pl";

my $input = new CGI;
my $op = $input->param('op') || '';
my $errors = [];

my $rule_from_cgi = sub {
    my ($cgi) = @_;

    my %rule = map { $_ => scalar $cgi->param($_) } (
        'tag',
        'module',
        'filter',
        'add',
        'append',
        'remove',
        'delete'
    );

    my $id = $cgi->param('id');
    if ($id) {
        $rule{id} = $id;
    }

    return \%rule;
};

my ($template, $loggedinuser, $cookie) = get_template_and_user(
    {
        template_name   => "admin/marc-merge-rules.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'manage_marc_merge_rules' },
        debug           => 1,
    }
);

$template->param(script_name => $script_name);

my %cookies = parse CGI::Cookie($cookie);
our $sessionID = $cookies{'CGISESSID'}->value;

my $get_rules = sub {
    # TODO: order?
    return [map { { $_->get_columns() } } Koha::MarcMergeRules->_resultset->all];
};
my $rules;

if ($op eq 'remove' || $op eq 'doremove') {
    my @remove_ids = $input->multi_param('batchremove');
    push @remove_ids, scalar $input->param('id') if $input->param('id');
    if ($op eq 'remove') {
        $template->{VARS}->{removeConfirm} = 1;
        my %remove_ids = map { $_ => undef } @remove_ids;
        $rules = $get_rules->();
        for my $rule (@{$rules}) {
            $rule->{'removemarked'} = 1 if exists $remove_ids{$rule->{id}};
        }
    }
    elsif ($op eq 'doremove') {
        my @remove_ids = $input->multi_param('batchremove');
        push @remove_ids, scalar $input->param('id') if $input->param('id');
        Koha::MarcMergeRules->search({ id => { in => \@remove_ids } })->delete();
        $rules = $get_rules->();
    }
}
elsif ($op eq 'edit') {
    $template->{VARS}->{edit} = 1;
    my $id = $input->param('id');
    $rules = $get_rules->();
    for my $rule(@{$rules}) {
        if ($rule->{id} == $id) {
            $rule->{'edit'} = 1;
            last;
        }
    }
}
elsif ($op eq 'doedit' || $op eq 'add') {
    my $rule_data = $rule_from_cgi->($input);
    if (!@{$errors}) {
        try {
            Koha::MarcMergeRules->validate($rule_data);
        }
        catch {
            die $_ unless blessed $_ && $_->can('rethrow');

            if ($_->isa('Koha::Exceptions::MarcMergeRule::InvalidTagRegExp')) {
                push @{$errors}, {
                    type => 'error',
                    code => 'invalid_tag_regexp',
                    tag => $rule_data->{tag},
                };
            }
            elsif ($_->isa('Koha::Exceptions::MarcMergeRule::InvalidControlFieldActions')) {
                push @{$errors}, {
                    type => 'error',
                    code => 'invalid_control_field_actions',
                    tag => $rule_data->{tag},
                };
            }
            else {
                $_->rethrow;
            }
        };
        if (!@{$errors}) {
            my $rule = Koha::MarcMergeRules->find_or_create($rule_data);
            # Need to call set and store here in case we have an update
            $rule->set($rule_data);
            $rule->store();
        }
        $rules = $get_rules->();
    }
}
else {
    $rules = $get_rules->();
}

my $categorycodes = Koha::Patron::Categories->search_limited({}, {order_by => ['description']});
$template->param( rules => $rules, categorycodes => $categorycodes, messages => $errors );

output_html_with_http_headers $input, $cookie, $template->output;
