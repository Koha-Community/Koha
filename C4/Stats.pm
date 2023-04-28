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

use Modern::Perl;
use Carp qw( croak );
use C4::Context;

use Koha::DateUtils qw( dt_from_string );
use Koha::Statistics;
use Koha::PseudonymizedTransactions;

our (@ISA, @EXPORT_OK);
BEGIN {
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT_OK = qw(
      UpdateStats
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
    ccode              : the collection code of the item
    categorycode       : the categorycode of the patron
    interface          : the context this action was taken in

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
    my @allowed_keys = qw (type branch amount other itemnumber itemtype borrowernumber ccode location categorycode interface);
    my @allowed_circulation_types = qw (renew issue localuse return onsite_checkout recall);
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
        push @invalid_params, $myparam unless grep { $_ eq $myparam } @allowed_keys;
    }
    if (scalar @invalid_params > 0 ) {
        croak ("UpdateStats received invalid param(s): ".join (", ",@invalid_params ));
    }
# get the parameters
    my $branch            = $params->{branch};
    my $type              = $params->{type};
    my $borrowernumber    = exists $params->{borrowernumber} ? $params->{borrowernumber} : '';
    my $itemnumber        = exists $params->{itemnumber}     ? $params->{itemnumber}     : undef;
    my $amount            = exists $params->{amount}         ? $params->{amount}         : 0;
    my $other             = exists $params->{other}          ? $params->{other}          : '';
    my $itemtype          = exists $params->{itemtype}       ? $params->{itemtype}       : '';
    my $location          = exists $params->{location}       ? $params->{location}       : undef;
    my $ccode             = exists $params->{ccode}          ? $params->{ccode}          : '';
    my $categorycode      = exists $params->{categorycode}   ? $params->{categorycode}   : undef;
    my $interface         = exists $params->{interface}      ? $params->{interface}      : undef;

    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    my $statistic = Koha::Statistic->new(
        {
            datetime       => $dtf->format_datetime( dt_from_string ),
            branch         => $branch,
            type           => $type,
            value          => $amount,
            other          => $other,
            itemnumber     => $itemnumber,
            itemtype       => $itemtype,
            location       => $location,
            borrowernumber => $borrowernumber,
            ccode          => $ccode,
            categorycode   => $categorycode,
            interface      => $interface,
        }
    )->store;

    Koha::PseudonymizedTransaction->new_from_statistic($statistic)->store
      if C4::Context->preference('Pseudonymization')
        && $borrowernumber # Not a real transaction if the patron does not exist
                           # For instance can be a transfer, or hold trigger
        && grep { $_ eq $params->{type} } qw(renew issue return onsite_checkout);
}

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut

