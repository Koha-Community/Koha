#! /usr/bin/perl

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
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::DateUtils qw( dt_from_string );
use Koha::Acquisition::Booksellers;
use Koha::ERM::Agreements;

my $input        = CGI->new;
my $agreement_id = $input->param('agreement_id');
my $op           = $input->param('op') || 'list';
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "erm/agreements.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { 'erm' => '1' },
    }
);

my $dbh = C4::Context->dbh;
if ( $op eq 'add_form' ) {
    my $agreement;
    if ($agreement_id) {
        $agreement = Koha::ERM::Agreements->find($agreement_id);
    }

    $template->param( agreement => $agreement, );
}
elsif ( $op eq 'add_validate' ) {
    my $vendor_id        = $input->param('vendor_id');
    my $name             = $input->param('name');
    my $description      = $input->param('description');
    my $status           = $input->param('status');
    my $closure_reason   = $input->param('closure_reason');
    my $is_perpetual     = $input->param('is_perpetual');
    my $renewal_priority = $input->param('renewal_priority');
    my $license_info     = $input->param('license_info');

    my $schema = Koha::Database->new->schema;
    $schema->txn_do(sub{
        my ( $stored, $agreement );
        if ($agreement_id) {
            $agreement = Koha::ERM::Agreements->find($agreement_id);
            $agreement->vendor_id($vendor_id);
            $agreement->name($name);
            $agreement->description($description);
            $agreement->status($status);
            $agreement->closure_reason($closure_reason);
            $agreement->is_perpetual($is_perpetual);
            $agreement->renewal_priority($renewal_priority);
            $agreement->license_info($license_info);

            eval { $agreement->store; };
            if ($@) {
                push @messages, { type => 'error', code => 'error_on_update' };
            }
            else {
                $stored = 1;
                push @messages, { type => 'message', code => 'success_on_update' };
            }
        }
        else {
            $agreement = Koha::ERM::Agreement->new(
                {
                    vendor_id        => $vendor_id,
                    name             => $name,
                    description      => $description,
                    status           => $status,
                    closure_reason   => $closure_reason,
                    is_perpetual     => $is_perpetual,
                    renewal_priority => $renewal_priority,
                    license_info     => $license_info,
                }
            );
            eval { $agreement->store; };
            if ($@) {
                push @messages, { type => 'error', code => 'error_on_insert' };
            }
            else {
                $stored = 1;
                push @messages, { type => 'message', code => 'success_on_insert' };
            }
        }

        if ( $stored ) {
            if ( $agreement_id ) {
                $agreement->periods->delete;
            }
            for my $unique_id ( $input->multi_param('period_unique_id') ) {
                my $started_on = $input->param( 'started_on_' . $unique_id );
                next unless $started_on;
                my $ended_on = $input->param( 'ended_on_' . $unique_id );
                my $cancellation_deadline = $input->param( 'cancellation_deadline_' . $unique_id );
                my $notes = $input->param( 'notes_' . $unique_id );

                $started_on = dt_from_string($started_on);
                $ended_on &&= dt_from_string($ended_on);
                $cancellation_deadline &&= dt_from_string($cancellation_deadline);

                Koha::ERM::Agreement::Period->new(
                    {
                        agreement_id          => $agreement->agreement_id,
                        started_on            => $started_on,
                        ended_on              => $ended_on,
                        cancellation_deadline => $cancellation_deadline,
                        notes                 => $notes,
                    }
                )->store;
            }
        }
    });
    $op = 'list';
}
elsif ( $op eq 'delete_confirm' ) {
    my $agreement = Koha::ERM::Agreements->find($agreement_id);
    $template->param( agreement => $agreement, );
}
elsif ( $op eq 'delete_confirmed' ) {
    my $agreement = Koha::ERM::Agreements->find($agreement_id);
    my $deleted   = eval { $agreement->delete; };

    if ( $@ or not $deleted ) {
        push @messages, { type => 'error', code => 'error_on_delete' };
    }
    else {
        push @messages, { type => 'message', code => 'success_on_delete' };
    }
    $op = 'list';
}

if ( $op eq 'list' ) {
    $template->param(
        agreements_count => Koha::ERM::Agreements->search->count );
}

$template->param(
    vendors      => Koha::Acquisition::Booksellers->search,
    agreement_id => $agreement_id,
    messages     => \@messages,
    op           => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
