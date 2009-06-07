package C4::Review;

# Copyright 2000-2002 Katipo Communications
#
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use warnings;

use C4::Context;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
	$VERSION = 3.00;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(getreview savereview updatereview numberofreviews
		getreviews getallreviews approvereview deletereview);
}

=head1 NAME

C4::Review - Perl Module containing routines for dealing with reviews of items

=head1 SYNOPSIS

  use C4::Review;

  my $review=getreview($biblionumber,$borrowernumber);
  savereview($biblionumber,$borrowernumber,$review);
  updatereview($biblionumber,$borrowernumber,$review);
  my $count=numberofreviews($biblionumber);
  my $reviews=getreviews($biblionumber);
  my $reviews=getallreviews($status);

=head1 DESCRIPTION

Review.pm provides many routines for manipulating reviews.

=head1 FUNCTIONS

=head2 getreview

  $review = getreview($biblionumber,$borrowernumber);

Takes a borrowernumber and a biblionumber and returns the review of that biblio

=cut

sub getreview {
    my ( $biblionumber, $borrowernumber ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query =
      "SELECT * FROM reviews WHERE biblionumber=? and borrowernumber=?";
    my $sth = $dbh->prepare($query);
    $sth->execute( $biblionumber, $borrowernumber );
    return $sth->fetchrow_hashref();
}

sub savereview {
    my ( $biblionumber, $borrowernumber, $review ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "INSERT INTO reviews (borrowernumber,biblionumber,
	review,approved,datereviewed) VALUES 
  (?,?,?,0,now())";
    my $sth = $dbh->prepare($query);
    $sth->execute( $borrowernumber, $biblionumber, $review);
}

sub updatereview {
    my ( $biblionumber, $borrowernumber, $review ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "UPDATE reviews SET review=?,datereviewed=now(),approved=0  WHERE borrowernumber=? and biblionumber=?";
    my $sth = $dbh->prepare($query);
    $sth->execute( $review, $borrowernumber, $biblionumber );
}

sub numberofreviews {
    my ($biblionumber) = @_;
    my $dbh            = C4::Context->dbh;
    my $query          =
      "SELECT count(*) FROM reviews WHERE biblionumber=? and approved=?";
    my $sth = $dbh->prepare($query);
    $sth->execute( $biblionumber, 1 );
	return $sth->fetchrow;
}

sub getreviews {
    my ( $biblionumber, $approved ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query =
"SELECT * FROM reviews WHERE biblionumber=? and approved=? order by datereviewed desc";
    my $sth = $dbh->prepare($query) || warn $dbh->err_str;
    $sth->execute( $biblionumber, $approved );
	return $sth->fetchall_arrayref({});
}

sub getallreviews {
    my ($status) = @_;
    my $dbh      = C4::Context->dbh;
    my $query    =
      "SELECT * FROM reviews WHERE approved=? order by datereviewed desc";
    my $sth = $dbh->prepare($query);
    $sth->execute($status);
	return $sth->fetchall_arrayref({});
}

=head2 approvereview

  approvereview($reviewid);

Takes a reviewid and marks that review approved

=cut

sub approvereview {
    my ($reviewid) = @_;
    my $dbh        = C4::Context->dbh();
    my $query      = "UPDATE reviews
               SET approved=?
               WHERE reviewid=?";
    my $sth = $dbh->prepare($query);
    $sth->execute( 1, $reviewid );
}

=head2 deletereview

  deletereview($reviewid);

Takes a reviewid and deletes it

=cut

sub deletereview {
    my ($reviewid) = @_;
    my $dbh        = C4::Context->dbh();
    my $query      = "DELETE FROM reviews
               WHERE reviewid=?";
    my $sth = $dbh->prepare($query);
    $sth->execute($reviewid);
}

1;
__END__

=head1 AUTHOR

Koha Team

=cut
