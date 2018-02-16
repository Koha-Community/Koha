#!/usr/bin/perl
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

use C4::Auth;
use C4::Output;

use Koha::Patrons;

my $input = CGI->new;

my $borrowernumber;
my $cardnumber;
my @all_holds;

my ($template, $loggedinuser, $cookie)= get_template_and_user({template_name => "members/holdshistory.tt",
                query => $input,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => {borrowers => 1},
                debug => 1,
                });

my $patron;

if ($input->param('cardnumber')) {
    $cardnumber = $input->param('cardnumber');
    $patron = Koha::Patrons->find( { cardnumber => $cardnumber } );
}
if ($input->param('borrowernumber')) {
    $borrowernumber = $input->param('borrowernumber');
    $patron = Koha::Patrons->find( $borrowernumber );
}

unless ( $patron ) {
    print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
    exit;
}

my $holds;
my $old_holds;

if ( $borrowernumber eq C4::Context->preference('AnonymousPatron') ){
    # use of 'eq' in the above comparison is intentional -- the
    # system preference value could be blank
    $template->param( is_anonymous => 1 );
} else {
    $holds = $patron->holds;
    $old_holds = $patron->old_holds;

    while (my $hold = $holds->next) {
        push @all_holds, $hold;
    }

    while (my $hold = $old_holds->next) {
        push @all_holds, $hold;
    }
}

if ( $patron->is_child) {
    my $patron_categories = Koha::Patron::Categories->search_limited({ category_type => 'A' }, {order_by => ['categorycode']});
    $template->param( 'CATCODE_MULTI' => 1) if $patron_categories->count > 1;
    $template->param( 'catcode' => $patron_categories->next->categorycode )  if $patron_categories->count == 1;
}

$template->param(
    holdshistoryview => 1,
    patron           => $patron,
    holds            => \@all_holds,
);

output_html_with_http_headers $input, $cookie, $template->output;
