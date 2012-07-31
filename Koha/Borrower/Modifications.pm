package Koha::Borrower::Modifications;

# Copyright 2012 ByWater Solutions
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

C4::Borrowers::Modifications

=cut

use Modern::Perl;

use C4::Context;
use C4::Debug;
use C4::SQLHelper qw(InsertInTable UpdateInTable);

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {

    # set the version for version checking
    $VERSION = 0.01;
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(

    );

    my $debug = C4::Context->preference("DebugLevel");
}

sub new {
    my ( $class, %args ) = @_;
    my $self = bless( {}, $class );

    $self->{'verification_token'} = $args{'verification_token'};
    $self->{'borrowernumber'}     = $args{'borrowernumber'};

    return $self;
}

=head AddModifications

Koha::Borrower::Modifications->AddModifications( %data );

Adds or updates modifications for a borrower.

Requires either the key borrowernumber, or verification_token
to be part of the passed in hash.

=cut

sub AddModifications {
    my ( $self, %data ) = @_;

    if ( $self->{'borrowernumber'} ) {
        delete $data{'borrowernumber'};

        if ( keys %data ) {
            $data{'borrowernumber'} = $self->{'borrowernumber'};
            my $dbh = C4::Context->dbh;

            my $query = "
                SELECT COUNT(*) AS count
                FROM borrower_modifications
                WHERE borrowernumber = ?
            ";

            my $sth = $dbh->prepare($query);
            $sth->execute( $self->{'borrowernumber'} );
            my $result = $sth->fetchrow_hashref();

            if ( $result->{'count'} ) {
                $data{'verification_token'} = q{};
                return UpdateInTable( "borrower_modifications", \%data );
            }
            else {
                return InsertInTable( "borrower_modifications", \%data );
            }
        }

    }
    elsif ( $self->{'verification_token'} ) {
        delete $data{'borrowernumber'};
        $data{'verification_token'} = $self->{'verification_token'};

        return InsertInTable( "borrower_modifications", \%data );
    }
    else {
        return;
    }
}

=head Verify

$verified = Koha::Borrower::Modifications->Verify( $verification_token );

Returns true if the passed in token is valid.

=cut

sub Verify {
    my ( $self, $verification_token ) = @_;

    if ( ref($self) ) {
        $verification_token =
          ($verification_token)
          ? $verification_token
          : $self->{'verification_token'};
    }

    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT COUNT(*) AS count
        FROM borrower_modifications
        WHERE verification_token = ?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($verification_token);
    my $result = $sth->fetchrow_hashref();

    return $result->{'count'};
}

=head GetPendingModificationsCount

$count = Koha::Borrower::Modifications->GetPendingModificationsCount();

Returns the number of pending modifications for existing borrowers.
=cut

sub GetPendingModificationsCount {
    my ( $self, $branchcode ) = @_;

    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT COUNT(*) AS count
        FROM borrower_modifications, borrowers
        WHERE borrower_modifications.borrowernumber > 0
        AND borrower_modifications.borrowernumber = borrowers.borrowernumber
    ";

    my @params;
    if ($branchcode) {
        $query .= " AND borrowers.branchcode = ? ";
        push( @params, $branchcode );
    }

    my $sth = $dbh->prepare($query);
    $sth->execute(@params);
    my $result = $sth->fetchrow_hashref();

    return $result->{'count'};
}

=head GetPendingModifications

$arrayref = Koha::Borrower::Modifications->GetPendingModifications();

Returns an arrayref of hashrefs for all pending modifications for existing borrowers.

=cut

sub GetPendingModifications {
    my ( $self, $branchcode ) = @_;

    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT borrower_modifications.*
        FROM borrower_modifications, borrowers
        WHERE borrower_modifications.borrowernumber > 0
        AND borrower_modifications.borrowernumber = borrowers.borrowernumber
    ";

    my @params;
    if ($branchcode) {
        $query .= " AND borrowers.branchcode = ? ";
        push( @params, $branchcode );
    }

    my $sth = $dbh->prepare($query);
    $sth->execute(@params);

    my @m;
    while ( my $row = $sth->fetchrow_hashref() ) {
        foreach my $key ( keys %$row ) {
            delete $row->{$key} unless defined $row->{$key};
        }

        push( @m, $row );
    }

    return \@m;
}

=head ApproveModifications

Koha::Borrower::Modifications->ApproveModifications( $borrowernumber );

Commits the pending modifications to the borrower record and removes
them from the modifications table.

=cut

sub ApproveModifications {
    my ( $self, $borrowernumber ) = @_;

    if ( ref($self) ) {
        $borrowernumber =
          ($borrowernumber) ? $borrowernumber : $self->{'borrowernumber'};
    }

    return unless $borrowernumber;

    my $data = $self->GetModifications( borrowernumber => $borrowernumber );

    if ( UpdateInTable( "borrowers", $data ) ) {
        $self->DelModifications( borrowernumber => $borrowernumber );
    }
}

=head DenyModifications

Koha::Borrower::Modifications->DenyModifications( $borrowernumber );

Removes the modifications from the table for the given borrower,
without commiting the changes to the borrower record.

=cut

sub DenyModifications {
    my ( $self, $borrowernumber ) = @_;

    if ( ref($self) ) {
        $borrowernumber =
          ($borrowernumber) ? $borrowernumber : $self->{'borrowernumber'};
    }

    return unless $borrowernumber;

    return $self->DelModifications( borrowernumber => $borrowernumber );
}

=head DelModifications

Koha::Borrower::Modifications->DelModifications(
  [ borrowernumber => $borrowernumber ],
  [ verification_token => $verification_token ]
);

Deletes the modifications for the given borrowernumber or verification token.

=cut

sub DelModifications {
    my ( $self, %params ) = @_;

    my ( $field, $value );

    if ( $params{'borrowernumber'} ) {
        $field = 'borrowernumber';
        $value = $params{'borrowernumber'};
    }
    elsif ( $params{'verification_token'} ) {
        $field = 'verification_token';
        $value = $params{'verification_token'};
    }

    if ( ref($self) && !$value ) {
        if ( $self->{'borrowernumber'} ) {
            $field = 'borrowernumber';
            $value = $self->{'borrowernumber'};
        }
        elsif ( $self->{'verification_token'} ) {
            $field = 'verification_token';
            $value = $self->{'verification_token'};
        }
    }

    return unless $value;

    my $dbh = C4::Context->dbh;

    $field = $dbh->quote_identifier($field);

    my $query = "
        DELETE
        FROM borrower_modifications
        WHERE $field = ?
    ";

    my $sth = $dbh->prepare($query);
    return $sth->execute($value);
}

=head GetModifications

$hashref = Koha::Borrower::Modifications->GetModifications(
  [ borrowernumber => $borrowernumber ],
  [ verification_token => $verification_token ]
);

Gets the modifications for the given borrowernumber or verification token.

=cut

sub GetModifications {
    my ( $self, %params ) = @_;

    my ( $field, $value );

    if ( $params{'borrowernumber'} ) {
        $field = 'borrowernumber';
        $value = $params{'borrowernumber'};
    }
    elsif ( $params{'verification_token'} ) {
        $field = 'verification_token';
        $value = $params{'verification_token'};
    }

    if ( ref($self) && !$value ) {
        if ( $self->{'borrowernumber'} ) {
            $field = 'borrowernumber';
            $value = $self->{'borrowernumber'};
        }
        elsif ( $self->{'verification_token'} ) {
            $field = 'verification_token';
            $value = $self->{'verification_token'};
        }
    }

    return unless $value;

    my $dbh = C4::Context->dbh;

    $field = $dbh->quote_identifier($field);

    my $query = "
        SELECT *
        FROM borrower_modifications
        WHERE $field = ?
    ";

    my $sth = $dbh->prepare($query);
    $sth->execute($value);
    my $data = $sth->fetchrow_hashref();

    foreach my $key ( keys %$data ) {
        delete $data->{$key} unless ( defined( $data->{$key} ) );
    }

    return $data;
}

1;
