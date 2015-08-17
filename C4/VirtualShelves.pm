package C4::VirtualShelves;

# Copyright 2000-2002 Katipo Communications
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

use strict;
use warnings;

use Carp;
use C4::Context;
use C4::Debug;
use C4::Members;

use constant SHELVES_MASTHEAD_MAX => 10; #number under Lists button in masthead
use constant SHELVES_COMBO_MAX => 10; #add to combo in search
use constant SHELVES_MGRPAGE_MAX => 20; #managing page
use constant SHELVES_POPUP_MAX => 40; #addbybiblio popup

use constant SHARE_INVITATION_EXPIRY_DAYS => 14; #two weeks to accept

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

BEGIN {
    # set the version for version checking
    $VERSION = 3.07.00.049;
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
    );
        @EXPORT_OK = qw(
            &ShelvesMax
        );
}


=head1 NAME

C4::VirtualShelves - Functions for manipulating Koha virtual shelves

=head1 SYNOPSIS

  use C4::VirtualShelves;

=head1 DESCRIPTION

This module provides functions for manipulating virtual shelves,
including creating and deleting virtual shelves, and adding and removing
bibs to and from virtual shelves.

=head1 FUNCTIONS

=head2 ShelvesMax

    $howmany= ShelvesMax($context);

Tells how much shelves are shown in which context.
POPUP refers to addbybiblionumber popup, MGRPAGE is managing page (in opac or
staff), COMBO refers to the Add to-combo of search results. MASTHEAD is the
main Koha toolbar with Lists button.

=cut

sub ShelvesMax {
    my $which= shift;
    return SHELVES_POPUP_MAX if $which eq 'POPUP';
    return SHELVES_MGRPAGE_MAX if $which eq 'MGRPAGE';
    return SHELVES_COMBO_MAX if $which eq 'COMBO';
    return SHELVES_MASTHEAD_MAX if $which eq 'MASTHEAD';
    return SHELVES_MASTHEAD_MAX;
}

=head2 HandleDelBorrower

     HandleDelBorrower($borrower);

When a member is deleted (DelMember in Members.pm), you should call me first.
This routine deletes/moves lists and entries for the deleted member/borrower.
Lists owned by the borrower are deleted, but entries from the borrower to
other lists are kept.

=cut

sub HandleDelBorrower {
    my ($borrower)= @_;
    my $query;
    my $dbh = C4::Context->dbh;

    #Delete all lists and all shares of this borrower
    #Consistent with the approach Koha uses on deleting individual lists
    #Note that entries in virtualshelfcontents added by this borrower to
    #lists of others will be handled by a table constraint: the borrower
    #is set to NULL in those entries.
    $query="DELETE FROM virtualshelves WHERE owner=?";
    $dbh->do($query,undef,($borrower));

    #NOTE:
    #We could handle the above deletes via a constraint too.
    #But a new BZ report 11889 has been opened to discuss another approach.
    #Instead of deleting we could also disown lists (based on a pref).
    #In that way we could save shared and public lists.
    #The current table constraints support that idea now.
    #This pref should then govern the results of other routines/methods such as
    #Koha::Virtualshelf->new->delete too.
}

sub GetShelfCount {
    my ($owner, $category) = @_;
    my @params;
    # Find out how many shelves total meet the submitted criteria...

    my $dbh = C4::Context->dbh;
    my $query = "SELECT count(*) FROM virtualshelves vs ";
    if($category==1) {
        $query.= qq{
            LEFT JOIN virtualshelfshares sh ON sh.shelfnumber=vs.shelfnumber
            AND sh.borrowernumber=?
        WHERE category=1 AND (vs.owner=? OR sh.borrowernumber=?) };
        @params= ($owner, $owner, $owner);
    }
    else {
        $query.='WHERE category=2';
        @params= ();
    }
    my $sth = $dbh->prepare($query);
    $sth->execute(@params);
    my ($total)= $sth->fetchrow;
    return $total;
}

1;

__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=head1 SEE ALSO

C4::Circulation::Circ2(3)

=cut
