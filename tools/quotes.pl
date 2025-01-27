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

use CGI       qw ( -utf8 );
use Try::Tiny qw( catch try );

use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use Koha::Quotes;

my $input = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "tools/quotes.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { tools => 'edit_quotes' },
    }
);

my $id = $input->param('id');
my $op = $input->param('op') || 'list';
my @messages;

if ( $op eq 'add_form' ) {
    $template->param( quote => Koha::Quotes->find($id), );
} elsif ( $op eq 'cud-add_validate' ) {
    my @fields = qw(
        source
        text
    );

    if ($id) {
        my $quote = Koha::Quotes->find($id);
        for my $field (@fields) {
            $quote->$field( scalar $input->param($field) );
        }

        try {
            $quote->store;
            push @messages, { type => 'message', code => 'success_on_update' };
        } catch {
            push @messages, { type => 'alert', code => 'error_on_update' };
        }
    } else {
        my $quote = Koha::Quote->new(
            {
                id => $id,
                ( map { $_ => scalar $input->param($_) || undef } @fields )
            }
        );

        try {
            $quote->store;
            push @messages, { type => 'message', code => 'success_on_insert' };
        } catch {
            push @messages, { type => 'alert', code => 'error_on_insert' };
        };
    }
    $op = 'list';
} else {
    $op = 'list';
}

$template->param( quotes_count => Koha::Quotes->search->count )
    if $op eq 'list';

$template->param(
    messages => \@messages,
    op       => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
