package Koha::Patron::Debarments;

# This file is part of Koha.
#
# Copyright 2013 ByWater Solutions
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

use C4::Context;
use C4::Log qw( logaction );

use Koha::Database;
use Koha::Patrons;
use Koha::Patron::Restriction::Types;
use Koha::Patron::Restrictions;

our ( @ISA, @EXPORT_OK );

BEGIN {
    require Exporter;
    @ISA       = qw(Exporter);
    @EXPORT_OK = qw(
        AddDebarment
        DelDebarment
        ModDebarment

        AddUniqueDebarment
        DelUniqueDebarment

    );
}

=head1 Koha::Patron::Debarments

Koha::Patron::Debarments - Module for managing patron debarments

=cut

=head2 AddDebarment

my $success = AddDebarment({
    borrowernumber => $borrowernumber,
    expiration     => $expiration,
    type           => $type, ## enum('FINES','OVERDUES','MANUAL')
    comment        => $comment,
});

Creates a new debarment.

Required keys: borrowernumber, type

=cut

sub AddDebarment {
    my ($params) = @_;

    my $borrowernumber = $params->{'borrowernumber'};
    my $expiration     = $params->{'expiration'} || undef;
    my $type           = $params->{'type'}       || 'MANUAL';
    my $comment        = $params->{'comment'}    || undef;

    return unless ( $borrowernumber && $type );

    my $manager_id;
    $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv;

    my $restriction = Koha::Patron::Restriction->new(
        {
            borrowernumber => $borrowernumber,
            expiration     => $expiration,
            type           => $type,
            comment        => $comment,
            manager_id     => $manager_id,
        }
    )->store();

    UpdateBorrowerDebarmentFlags($borrowernumber);

    logaction( "MEMBERS", "CREATE_RESTRICTION", $borrowernumber, $restriction )
        if C4::Context->preference("BorrowersLog");

    return $restriction ? 1 : 0;
}

=head2 DelDebarment

my $success = DelDebarment( $borrower_debarment_id );

Deletes a debarment.

=cut

sub DelDebarment {
    my ($borrower_debarment_id) = @_;

    my $restriction = Koha::Patron::Restrictions->find($borrower_debarment_id);

    return unless $restriction;

    Koha::Database->new->schema->txn_do(
        sub {
            my $borrowernumber = $restriction->borrowernumber;
            logaction( "MEMBERS", "DELETE_RESTRICTION", $borrowernumber, $restriction )
                if C4::Context->preference("BorrowersLog");

            $restriction->delete;
            UpdateBorrowerDebarmentFlags($borrowernumber);
        }
    );

    return 1;
}

=head2 ModDebarment

my $success = ModDebarment({
    borrower_debarment_id => $borrower_debarment_id,
    expiration            => $expiration,
    type                  => $type, ## enum('FINES','OVERDUES','MANUAL','DISCHARGE')
    comment               => $comment,
});

Updates an existing debarment.

Required keys: borrower_debarment_id

=cut

sub ModDebarment {
    my ($params) = @_;

    my $borrower_debarment_id = $params->{'borrower_debarment_id'};

    return unless ($borrower_debarment_id);

    delete( $params->{'borrower_debarment_id'} );

    delete( $params->{'created'} );
    delete( $params->{'updated'} );

    $params->{'manager_id'} = C4::Context->userenv->{'number'} if C4::Context->userenv;

    my @keys   = keys %$params;
    my @values = values %$params;

    my $sql = join( ',', map { "$_ = ?" } @keys );

    $sql = "UPDATE borrower_debarments SET $sql, updated = NOW() WHERE borrower_debarment_id = ?";

    my $r = C4::Context->dbh->do( $sql, {}, ( @values, $borrower_debarment_id ) );

    my $borrowernumber = _GetBorrowernumberByDebarmentId($borrower_debarment_id);
    UpdateBorrowerDebarmentFlags($borrowernumber);

    logaction(
        "MEMBERS", "MODIFY_RESTRICTION", $borrowernumber,
        Koha::Patron::Restrictions->find($borrower_debarment_id)
    ) if C4::Context->preference("BorrowersLog");

    return $r;
}

=head2 AddUniqueDebarment

my $success = AddUniqueDebarment({
    borrowernumber => $borrowernumber,
    type           => $type,
    expiration     => $expiration,
    comment        => $comment,
});

Creates a new debarment of the type defined by the key type.
If a unique debarment already exists of the given type, it is updated instead.
The current unique debarment types are OVERDUES, SUSPENSION, and FINES

Required keys: borrowernumber, type

=cut

sub AddUniqueDebarment {
    my ($params) = @_;

    my $borrowernumber = $params->{'borrowernumber'};
    my $type           = $params->{'type'};

    return unless ( $borrowernumber && $type );

    my $patron = Koha::Patrons->find($borrowernumber);
    return unless $patron;

    my $debarment =
        $patron->restrictions->search( { type => $type }, { rows => 1 } )->single;

    my $r;
    if ($debarment) {

        # We don't want to shorten a unique debarment's period, so if this 'update' would do so, just keep the current expiration date instead
        $params->{'expiration'} = $debarment->expiration
            if ( $debarment->expiration
            && $debarment->expiration gt $params->{'expiration'} );

        $params->{'borrower_debarment_id'} = $debarment->borrower_debarment_id;
        $r = ModDebarment($params);
    } else {

        $r = AddDebarment($params);
    }

    UpdateBorrowerDebarmentFlags($borrowernumber);

    return $r;
}

=head2 DelUniqueDebarment

my $success = _DelUniqueDebarment({
    borrowernumber => $borrowernumber,
    type           => $type,
});

Deletes a unique debarment of the type defined by the key type.
The current unique debarment types are OVERDUES, SUSPENSION, and FINES

Required keys: borrowernumber, type

=cut

sub DelUniqueDebarment {
    my ($params) = @_;

    my $borrowernumber = $params->{'borrowernumber'};
    my $type           = $params->{'type'};

    return unless ( $borrowernumber && $type );

    my $patron = Koha::Patrons->find($borrowernumber);
    return unless $patron;

    my $debarment =
        $patron->restrictions->search( { type => $type }, { rows => 1 } )->single;

    return unless ($debarment);

    return DelDebarment( $debarment->borrower_debarment_id );
}

=head2 UpdateBorrowerDebarmentFlags

my $success = UpdateBorrowerDebarmentFlags( $borrowernumber );

So as not to create additional latency, the fields borrowers.debarred
and borrowers.debarredcomment remain in the borrowers table. Whenever
the a borrowers debarrments are modified, this subroutine is run to
decide if the borrower is currently debarred and update the 'quick flags'
in the borrowers table accordingly.

=cut

sub UpdateBorrowerDebarmentFlags {
    my ($borrowernumber) = @_;

    return unless ($borrowernumber);

    my $dbh = C4::Context->dbh;

    my $sql = q{
        SELECT COUNT(*), COUNT(*) - COUNT(expiration), MAX(expiration), GROUP_CONCAT(comment SEPARATOR '\n') FROM borrower_debarments
        WHERE ( expiration > CURRENT_DATE() OR expiration IS NULL ) AND borrowernumber = ?
    };
    my $sth = $dbh->prepare($sql);
    $sth->execute($borrowernumber);
    my ( $count, $indefinite_expiration, $expiration, $comment ) = $sth->fetchrow_array();

    if ($count) {
        $expiration = "9999-12-31" if ($indefinite_expiration);
    } else {
        $expiration = undef;
        $comment    = undef;
    }

    return $dbh->do(
        "UPDATE borrowers SET debarred = ?, debarredcomment = ? WHERE borrowernumber = ?", {},
        ( $expiration, $comment, $borrowernumber )
    );
}

=head2 del_restrictions_after_payment

    my $success = del_restrictions_after_payment({
        borrowernumber => $borrowernumber,
    });

Deletes any restrictions from patron by following the rules
defined in "Patron restrictions".

=cut

sub del_restrictions_after_payment {
    my ($params) = @_;

    my $borrowernumber = $params->{'borrowernumber'};
    return unless ($borrowernumber);

    my $patron = Koha::Patrons->find($borrowernumber);
    return unless ($patron);

    my $restrictions = $patron->restrictions;
    return unless ( $restrictions->count );

    my $lines     = Koha::Account::Lines->search( { borrowernumber => $borrowernumber } );
    my $total_due = $lines->total_outstanding;

    while ( my $restriction = $restrictions->next ) {
        if (   $restriction->type->lift_after_payment
            && $total_due <= $restriction->type->fee_limit )
        {
            DelDebarment( $restriction->borrower_debarment_id );
        }
    }
}

=head2 _GetBorrowernumberByDebarmentId

my $borrowernumber = _GetBorrowernumberByDebarmentId( $borrower_debarment_id );

=cut

sub _GetBorrowernumberByDebarmentId {
    my ($borrower_debarment_id) = @_;

    return unless ($borrower_debarment_id);

    my $sql = "SELECT borrowernumber FROM borrower_debarments WHERE borrower_debarment_id = ?";
    my $sth = C4::Context->dbh->prepare($sql);
    $sth->execute($borrower_debarment_id);
    my ($borrowernumber) = $sth->fetchrow_array();

    return $borrowernumber;
}

1;

=head2 AUTHOR

Kyle M Hall <kyle@bywatersoltuions.com>

=cut
