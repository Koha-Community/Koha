#!/usr/bin/perl

# Copyright 2015 Open Source Freedom Fighters
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

use Test::More; #Please don't set the test count here. It is nothing but trouble when rebasing against master and is of dubious help.

use Koha::Patron;



testIsSuperuser();





################################################################################
#### Define test subroutines here ##############################################
################################################################################

=head testIsSuperuser
@UNIT_TEST
Tests Koha::Patron->isSuperuser()
=cut

sub testIsSuperuser {
    my $borrower = Koha::Patron->new();
    ok((not(defined($borrower->isSuperuser()))), "isSuperuser(): By default user is not defined as superuser.");
    ok(($borrower->isSuperuser(1) == 1), "isSuperuser(): Setting user as superuser returns 1.");
    ok(($borrower->isSuperuser() == 1), "isSuperuser(): Getting superuser status from a superuser returns 1.");
    ok((not(defined($borrower->isSuperuser(0)))), "isSuperuser(): Removing superuser status from a superuser OK and returns undef");
    ok((not(defined($borrower->isSuperuser()))), "isSuperuser(): Ex-superuser superuser status is undef");
}




#######################
done_testing(); #YAY!!
#######################
