package C4::Stats;


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
require Exporter;
use Carp;
use C4::Context;
use C4::Debug;
use vars qw($VERSION @ISA @EXPORT);

our $debug;

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		&UpdateStats
		&TotalPaid
	);
}


=head1 NAME

C4::Stats - Update Koha statistics (log)

=head1 SYNOPSIS

  use C4::Stats;

=head1 DESCRIPTION

The functions of this module deals with statistics table of Koha database.

=head1 FUNCTIONS

=head2 UpdateStats

  &UpdateStats($params);

Adds an entry to the statistics table in the Koha database, which acts as an activity log.

C<$params> is an hashref whose expected keys are:
    branch             : the branch where the transaction occurred
    type               : the type of transaction (renew, issue, localuse, return, writeoff, payment
    itemnumber         : the itemnumber of the item
    borrowernumber     : the borrowernumber of the patron
    amount             : the amount of the transaction
    other              : sipmode
    itemtype           : the type of the item
    accountno          : the count
    ccode              : the collection code of the item

type key is mandatory.
For types used in C4::Circulation (renew,issue,localuse,return), the following other keys are mandatory:
branch, borrowernumber, itemnumber, ccode, itemtype
For types used in C4::Accounts (writeoff, payment), the following other keys are mandatory:
branch, borrowernumber, itemnumber, ccode, itemtype
If an optional key is not provided, the value '' is used for this key.

Returns undef if no C<$param> is given

=cut

sub UpdateStats {
    my ($params) = @_;
# make some controls
    return () if ! defined $params;
# change these arrays if new types of transaction or new parameters are allowed
    my @allowed_keys = qw (type branch amount other itemnumber itemtype borrowernumber accountno ccode);
    my @allowed_circulation_types = qw (renew issue localuse return onsite_checkout);
    my @allowed_accounts_types = qw (writeoff payment);
    my @circulation_mandatory_keys = qw (type branch borrowernumber itemnumber ccode itemtype);
    my @accounts_mandatory_keys = qw (type branch borrowernumber amount);

    my @mandatory_keys = ();
    if (! exists $params->{type} or ! defined $params->{type}) {
        croak ("UpdateStats did not received type param");
    }
    if (grep ($_ eq $params->{type}, @allowed_circulation_types  )) {
        @mandatory_keys = @circulation_mandatory_keys;
    } elsif (grep ($_ eq $params->{type}, @allowed_accounts_types )) {
        @mandatory_keys = @accounts_mandatory_keys;
    } else {
        croak ("UpdateStats received forbidden type param: ".$params->{type});
    }
    my @missing_params = ();
    for my $mykey (@mandatory_keys ) {
        push @missing_params, $mykey if !grep (/^$mykey/, keys %$params);
    }
    if (scalar @missing_params > 0 ) {
        croak ("UpdateStats did not received mandatory param(s): ".join (", ",@missing_params ));
    }
    my @invalid_params = ();
    for my $myparam (keys %$params ) {
        push @invalid_params, $myparam unless grep (/^$myparam$/, @allowed_keys);
    }
    if (scalar @invalid_params > 0 ) {
        croak ("UpdateStats received invalid param(s): ".join (", ",@invalid_params ));
    }
# get the parameters
    my $branch            = $params->{branch};
    my $type              = $params->{type};
    my $borrowernumber    = exists $params->{borrowernumber} ? $params->{borrowernumber} :'';
    my $itemnumber        = exists $params->{itemnumber}     ? $params->{itemnumber} :'';
    my $amount            = exists $params->{amount}         ? $params->{amount} :'';
    my $other             = exists $params->{other}          ? $params->{other} :'';
    my $itemtype          = exists $params->{itemtype}       ? $params->{itemtype} :'';
    my $accountno         = exists $params->{accountno}      ? $params->{accountno} :'';
    my $ccode             = exists $params->{ccode}          ? $params->{ccode} :'';

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        "INSERT INTO statistics
        (datetime,
         branch,          type,        value,
         other,           itemnumber,  itemtype,
         borrowernumber,  proccode,    ccode)
         VALUES (now(),?,?,?,?,?,?,?,?,?)"
    );
    $sth->execute(
        $branch,         $type,        $amount,
        $other,          $itemnumber,  $itemtype,
        $borrowernumber, $accountno,   $ccode
    );
}

=head2 TotalPaid

  @total = &TotalPaid ( $time, [$time2], [$spreadsheet ]);

Returns an array containing the payments and writeoffs made between two dates
C<$time> and C<$time2>, or on a specific one, or from C<$time> onwards.

C<$time> param is mandatory.
If C<$time> eq 'today', returns are limited to the current day
If C<$time2> eq '', results are returned from C<$time> onwards.
If C<$time2> is undef, returns are limited to C<$time>
C<$spreadsheet> param is optional and controls the sorting of the results.

Returns undef if no param is given

=cut

sub TotalPaid {
    my ( $time, $time2, $spreadsheet ) = @_;
    return () unless (defined $time);
    $time2 = $time unless $time2;
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT * FROM statistics 
  LEFT JOIN borrowers ON statistics.borrowernumber= borrowers.borrowernumber
  WHERE (statistics.type='payment' OR statistics.type='writeoff') ";
    if ( $time eq 'today' ) {
# FIXME wrong condition. Now() will not get all the payments of the day but of a specific timestamp
        $query .= " AND datetime = now()";
    } else {
        $query .= " AND datetime > '$time'";    # FIXME: use placeholders
    }
    if ( $time2 ne '' ) {
        $query .= " AND datetime < '$time2'";   # FIXME: use placeholders
    }
# FIXME if $time2 is undef, query will be "AND datetime > $time AND AND datetime < $time"
# Operators should probably be <= and >=
    if ($spreadsheet) {
        $query .= " ORDER BY branch, type";
    }
    $debug and warn "TotalPaid query: $query";
    my $sth = $dbh->prepare($query);
    $sth->execute();
    return @{$sth->fetchall_arrayref({})};
}

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut

