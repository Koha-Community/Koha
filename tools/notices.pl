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

use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::Notice::Messages;
use Koha::DateUtils qw( dt_from_string );

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "tools/notices.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { tools => 'view_generated_notices' },
    }
);

unless ( C4::Context->preference('NoticesManagement') ) {
    print $query->redirect('/cgi-bin/koha/tools/tools-home.pl');
}

my $op = $query->param('op');

if ( $op and $op eq 'cud-search' ) {
    my $letter_code  = $query->param('letter_code')  || undef;
    my $categorycode = $query->param('categorycode') || undef;
    my $branchcode   = $query->param('branchcode')   || undef;
    my $from         = $query->param('from')         || undef;
    my $to           = $query->param('to')           || undef;
    my $status       = $query->param('status')       || undef;

    my %where = ();
    $where{'me.letter_code'}              = $letter_code  if ($letter_code);
    $where{'borrowernumber.categorycode'} = $categorycode if ($categorycode);
    $where{'borrowernumber.branchcode'}   = $branchcode   if ($branchcode);
    if ($from) {
        if ($to) {
            $where{'me.time_queued'} = [
                -and => { '<=', $to },
                { '>=', $from }
            ];
        } else {
            $where{'me.time_queued'} = { '>=', $from };
        }
    } elsif ($to) {
        $where{'me.time_queued'} = { '<=', $to };
    }
    $where{'me.status'} = $status if ($status);

    my $notices = Koha::Notice::Messages->search_limited(
        {%where},
        { order_by => { -desc => 'time_queued' } }
    );

    $template->param(
        notices      => $notices,
        letter_code  => $letter_code,
        categorycode => $categorycode,
        branchcode   => $branchcode,
        from         => $from,
        to           => $to,
        status       => $status,
    );
}

$template->param(
    letters => Koha::Notice::Templates->search(
        {}, { select => [ 'name', 'code' ], group_by => [ 'name', 'code' ], order_by => { -asc => 'code' } }
    ),
    attribute_type_codes => (
        C4::Context->preference('ExtendedPatronAttributes')
        ? [ Koha::Patron::Attribute::Types->search( { staff_searchable => 1 } )->get_column('code') ]
        : []
    ),
);

output_html_with_http_headers $query, $cookie, $template->output;
