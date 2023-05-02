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

use CGI qw ( -utf8 );
use Try::Tiny;

use C4::Context;
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::ImportBatch;
use Koha::MarcOverlayRules;
use Koha::Patron::Categories;

my $input = CGI->new;
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
        template_name   => "admin/marc-overlay-rules.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { parameters => 'manage_marc_overlay_rules' },
    }
);

my $get_rules = sub {
    return Koha::MarcOverlayRules->search( undef, { order_by => { -asc => 'id' } } )->unblessed;
};
my $rules = $get_rules->();

if ($op eq 'remove' || $op eq 'doremove') {
    my @remove_ids = $input->multi_param('batchremove');
    push @remove_ids, scalar $input->param('id') if $input->param('id');
    if ($op eq 'remove') {
        $template->{VARS}->{removeConfirm} = 1;
        my %remove_ids = map { $_ => undef } @remove_ids;
        for my $rule (@{$rules}) {
            $rule->{'removemarked'} = 1 if exists $remove_ids{$rule->{id}};
        }
    }
    elsif ($op eq 'doremove') {
        my @remove_ids = $input->multi_param('batchremove');
        push @remove_ids, scalar $input->param('id') if $input->param('id');
        Koha::MarcOverlayRules->search({ id => { in => \@remove_ids } })->delete();
        # Update $rules after deletion
        $rules = $get_rules->();
    }
}
elsif ($op eq 'edit') {
    $template->param( edit => 1 );
    my $id = $input->param('id');
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
            Koha::MarcOverlayRules->validate($rule_data);
        }
        catch {
            die $_ unless blessed $_ && $_->can('rethrow');

            if ($_->isa('Koha::Exceptions::MarcOverlayRule::InvalidTagRegExp')) {
                push @{$errors}, {
                    type => 'error',
                    code => 'invalid_tag_regexp',
                    tag => $rule_data->{tag},
                };
            }
            elsif ($_->isa('Koha::Exceptions::MarcOverlayRule::InvalidControlFieldActions')) {
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
            my $rule = Koha::MarcOverlayRules->find_or_create($rule_data);
            # Need to call set and store here in case we have an update
            $rule->set($rule_data);
            $rule->store();
        }
        # Update $rules after edit/add
        $rules = $get_rules->();
    }
}

my $categories = Koha::Patron::Categories->search_with_library_limits( {},
    { order_by => ['description'] } )->unblessed;

$template->param(
    rules      => $rules,
    categories => $categories,
    messages   => $errors
);

output_html_with_http_headers $input, $cookie, $template->output;
