#!/usr/bin/perl

# Copyright 2019 Koha Development Team
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

use Modern::Perl;
use CGI qw ( -utf8 );
use Try::Tiny qw( catch try );

use C4::Context;
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Account::DebitType;
use Koha::Account::DebitTypes;

my $input = CGI->new;
my $code  = $input->param('code');
my $op    = $input->param('op') || 'list';
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/debit_types.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { parameters => 'manage_accounts' },
    }
);

my $debit_type;
if ($code) {
    $debit_type = Koha::Account::DebitTypes->find($code);
}

if ( $op eq 'add_form' ) {

    my $selected_branches =
      $debit_type ? $debit_type->get_library_limits : undef;
    my $branches =
      Koha::Libraries->search( {}, { order_by => ['branchname'] } )->unblessed;
    my @branches_loop;
    foreach my $branch (@$branches) {
        my $selected =
          ( $selected_branches
              && grep { $_->branchcode eq $branch->{branchcode} }
              @{ $selected_branches->as_list } ) ? 1 : 0;
        push @branches_loop,
          {
            branchcode => $branch->{branchcode},
            branchname => $branch->{branchname},
            selected   => $selected,
          };
    }

    $template->param(
        debit_type    => $debit_type,
        branches_loop => \@branches_loop
    );
}
elsif ( $op eq 'add_validate' ) {
    my $description           = $input->param('description');
    my $can_be_invoiced = $input->param('can_be_invoiced') || 0;
    my $can_be_sold = $input->param('can_be_sold') || 0;
    my $default_amount        = $input->param('default_amount') || undef;
    my @branches = grep { $_ ne q{} } $input->multi_param('branches');

    if ( not defined $debit_type ) {
        $debit_type = Koha::Account::DebitType->new( { code => $code } );
    }
    $debit_type->description($description);
    $debit_type->can_be_invoiced($can_be_invoiced);
    $debit_type->can_be_sold($can_be_sold);
    $debit_type->default_amount($default_amount);

    try {
        $debit_type->store;
        $debit_type->replace_library_limits( \@branches );
        push @messages, { type => 'message', code => 'success_on_saving' };
    }
    catch {
        push @messages, { type => 'error', code => 'error_on_saving' };
    };
    $op = 'list';
}
elsif ( $op eq 'archive' ) {
    try {
        $debit_type->archived(1)->store();
        push @messages, { code => 'success_on_archive', type => 'message' };
    }
    catch {
        push @messages, { code => 'error_on_archive', type => 'alert' };

    };
    $op = 'list';
}
elsif ( $op eq 'unarchive' ) {
    try {
        $debit_type->archived(0)->store();
        push @messages, { code => 'success_on_restore', type => 'message' };
    }
    catch {
        push @messages, { code => 'error_on_restore', type => 'alert' };
    };
    $op = 'list';
}

if ( $op eq 'list' ) {
    my $debit_types = Koha::Account::DebitTypes->search();
    $template->param( debit_types => $debit_types, );
}

$template->param(
    code     => $code,
    messages => \@messages,
    op       => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
