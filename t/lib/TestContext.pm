package t::lib::TestContext;

# Copyright KohaSuomi 2016
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

use Modern::Perl;
use Carp;
use Scalar::Util qw(blessed);
use Try::Tiny;

use C4::Context;

use t::lib::TestObjects::PatronFactory;

=head setUserenv

Sets the C4::Context->userenv with nice default values, like:
 -Being in 'CPL'

@PARAM1 Koha::Patron, this object must be persisted to DB beforehand, sets the userenv for this borrower
        or PatronFactory-params, which create a new borrower and set the userenv for it.
@RETURNS Koha::Patron, the userenv borrower if it was created

=cut

sub setUserenv {
    my ($borrowerFactoryParams, $testContext) = @_;

    my $borrower;
    if ($borrowerFactoryParams) {
        if (blessed($borrowerFactoryParams) && $borrowerFactoryParams->isa('Koha::Patron')) {
            #We got a nice persisted borrower
            $borrower = $borrowerFactoryParams;
        }
        else {
            $borrower = t::lib::TestObjects::PatronFactory->createTestGroup( $borrowerFactoryParams, undef, $testContext );
        }
        C4::Context->_new_userenv('DUMMY SESSION');
        C4::Context::set_userenv($borrower->borrowernumber, $borrower->userid, $borrower->cardnumber, $borrower->firstname, $borrower->surname, $borrower->branchcode, 'Library 1', {}, $borrower->email, '', '');
        return $borrower;
    }
    else {
        C4::Context->_new_userenv('DUMMY SESSION');
        C4::Context::set_userenv(0,0,0,'firstname','surname', 'CPL', 'CPL', {}, 'dummysession@example.com', '', '');
    }
}

1;
