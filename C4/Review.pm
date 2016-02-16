package C4::Review;

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

use C4::Context;

use vars qw(@ISA @EXPORT);

BEGIN {
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(savereview updatereview numberofreviewsbybiblionumber);
}

=head1 NAME

C4::Review - Perl Module containing routines for dealing with reviews of items

=head1 SYNOPSIS

  use C4::Review;

  savereview($biblionumber,$borrowernumber,$review);
  updatereview($biblionumber,$borrowernumber,$review);
  my $count=numberofreviewsbybiblionumber($biblionumber);

=head1 DESCRIPTION

Review.pm provides many routines for manipulating reviews.

=head1 FUNCTIONS

=head2 savereview

  savereview($biblionumber,$borrowernumber, $review);

Save a review in the 'reviews' database

=cut

sub savereview {
    my ( $biblionumber, $borrowernumber, $review ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "INSERT INTO reviews (borrowernumber,biblionumber,
  review,approved,datereviewed) VALUES
  (?,?,?,0,now())";
    my $sth = $dbh->prepare($query);
    $sth->execute( $borrowernumber, $biblionumber, $review );
}

=head2 updatereview

  updateview($biblionumber,$borrowernumber, $review);

Update the review description in the 'reviews' database

=cut

sub updatereview {
    my ( $biblionumber, $borrowernumber, $review ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "UPDATE reviews SET review=?,datereviewed=now(),approved=0  WHERE borrowernumber=? and biblionumber=?";
    my $sth   = $dbh->prepare($query);
    $sth->execute( $review, $borrowernumber, $biblionumber );
}

=head2 numberofreviewsbybiblionumber

  my $count=numberofreviewsbybiblionumber($biblionumber);

Return the number of reviews approved for a given biblionumber

=cut

sub numberofreviewsbybiblionumber {
    my ($biblionumber) = @_;
    my $dbh            = C4::Context->dbh;
    my $query          = "SELECT count(*) FROM reviews WHERE biblionumber=? and approved=?";
    my $sth            = $dbh->prepare($query);
    $sth->execute( $biblionumber, 1 );
    return $sth->fetchrow;
}

1;
__END__

=head1 AUTHOR

Koha Team

=cut
