#! /usr/bin/perl

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
use C4::Context;
use C4::Auth;
use C4::Output;

use Koha::Account::DebitType;
use Koha::Account::DebitTypes;

my $input = new CGI;
my $code  = $input->param('code');
my $op    = $input->param('op') || 'list';
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/debit_types.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'parameters_remaining_permissions' },
        debug           => 1,
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
    my $can_be_added_manually = $input->param('can_be_added_manually') || 0;
    my $default_amount        = $input->param('default_amount') || undef;
    my @branches = grep { $_ ne q{} } $input->multi_param('branches');

    if ( not defined $debit_type ) {
        $debit_type = Koha::Account::DebitType->new( { code => $code } );
    }
    $debit_type->description($description);
    $debit_type->can_be_added_manually($can_be_added_manually);
    $debit_type->default_amount($default_amount);

    eval {
        $debit_type->store;
        $debit_type->replace_library_limits( \@branches );
    };
    if ($@) {
        push @messages, { type => 'error', code => 'error_on_saving' };
    }
    else {
        push @messages, { type => 'message', code => 'success_on_saving' };
    }
    $op = 'list';
}
elsif ( $op eq 'delete_confirm' ) {
    $template->param( debit_type => $debit_type );
}
elsif ( $op eq 'delete_confirmed' ) {
    my $deleted = eval { $debit_type->delete; };

    if ( $@ or not $deleted ) {
        push @messages, { type => 'error', code => 'error_on_delete' };
    }
    else {
        push @messages, { type => 'message', code => 'success_on_delete' };
    }
    $op = 'list';
}

if ( $op eq 'list' ) {
    my $debit_types = Koha::Account::DebitTypes->search();
    $template->param(
        debit_types  => $debit_types,
    );
}

$template->param(
    code     => $code,
    messages => \@messages,
    op       => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
