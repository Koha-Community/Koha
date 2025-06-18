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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI;

use C4::Auth qw( checkauth );

my $cgi = CGI->new;

my $authnotrequired = 0;
my $flags           = {
    borrowers     => 'edit_borrowers',
    updatecharges => 'remaining_permissions'
};

my $type = 'intranet';
my ( $user, $cookie ) = C4::Auth::checkauth( $cgi, $authnotrequired, $flags, $type );

my $op = $cgi->param('op') // q{};

if ( $op eq "cud-cancel" ) {
    my $accountlines_id    = $cgi->param('accountlines_id');
    my $cancel_charge_note = $cgi->param('cancel_charge_note');
    my $charge             = Koha::Account::Lines->find($accountlines_id);
    my $borrowernumber     = $charge->patron->borrowernumber;
    $charge->cancel(
        {
            branch   => C4::Context->userenv->{'branch'},
            staff_id => C4::Context->userenv->{'number'},
            note     => $cancel_charge_note,
        }
    );
    print $cgi->redirect( '/cgi-bin/koha/members/boraccount.pl?borrowernumber=' . $borrowernumber );
    exit;
}

print $cgi->redirect('/cgi-bin/koha/errors/403.pl');
