package Koha::Libraries;

# Copyright 2015 Koha Development team
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

use Modern::Perl;

use Carp;

use C4::Context;

use Koha::Biblios;
use Koha::Database;
use Koha::Item::Transfer::Limits;
use Koha::Items;
use Koha::Library;

use YAML::XS;
use DateTime;
use Data::Dumper;

use Koha::Logger;

use base qw(Koha::Objects);

=head1 NAME

Koha::Libraries - Koha Library Object set class

=head1 API

=head2 Class Methods

=cut

=head3 pickup_locations

Returns available pickup locations for
    A. a specific item
    B. a biblio
    C. none of the above, simply all libraries with pickup_location => 1

This method determines the pickup location by two factors:
    1. is the library configured as pickup location
    2. can a specific item / at least one of the items of a biblio be transferred
       into the library

OPTIONAL PARAMETERS:
    item   # Koha::Item object / itemnumber, find pickup locations for item
    biblio # Koha::Biblio object / biblionumber, find pickup locations for biblio

If no parameters are given, all libraries with pickup_location => 1 are returned.

=cut

sub pickup_locations {
    my ($self, $params) = @_;

    my $item = $params->{'item'};
    my $biblio = $params->{'biblio'};
    if ($biblio && $item) {
        Koha::Exceptions::BadParameter->throw(
            error => "Koha::Libraries->pickup_locations takes either 'biblio' or "
            ." 'item' as parameter, but not both."
        );
    }

    # Select libraries that are configured as pickup locations
    my $libraries = $self->search({
        pickup_location => 1
    }, {
        order_by => ['branchname']
    });

    return $libraries->unblessed unless $item or $biblio;
    return $libraries->unblessed
        unless C4::Context->preference('UseBranchTransferLimits');
    my $limittype = C4::Context->preference('BranchTransferLimitsType');

    my $items;
    if ($item) {
        unless (ref($item) eq 'Koha::Item') {
            $item = Koha::Items->find($item);
            return $libraries->unblessed unless $item;
        }
    } else {
        unless (ref($biblio) eq 'Koha::Biblio') {
            $biblio = Koha::Biblios->find($biblio);
            return $libraries->unblessed unless $biblio;
        }
    }

    my @pickup_locations;
    foreach my $library ($libraries->as_list) {
        if ($item && $item->can_be_transferred({ to => $library })) {
            push @pickup_locations, $library->unblessed;
        } elsif ($biblio && $biblio->can_be_transferred({ to => $library })) {
            push @pickup_locations, $library->unblessed;
        }
    }

    return wantarray ? @pickup_locations : \@pickup_locations;
}

=head3 search_filtered

=cut

sub search_filtered {
    my ( $self, $params, $attributes ) = @_;

    if ( C4::Context::only_my_library ) {
        $params->{branchcode} = C4::Context->userenv->{branch};
    }

    return $self->SUPER::search( $params, $attributes );
}

=head2 isOpen

  my $open = Koha::Libraries::isOpen($branchcode || 'CPL' [, $DateTime]);

@PARAM1 String, branchcode
@PARAM2 DateTime, OPTIONAL time to check for openness. Defaults to current time | now().
@RETURNS Boolean, Library is open or not
@THROWS from _getOpeningHoursFromSyspref()

=cut

sub isOpen {
    my ($branchcode, $dt) = @_;

    $dt = DateTime->now(time_zone => C4::Context->tz()) unless $dt;
    my $hm = sprintf("%02d:%02d", $dt->hour,$dt->minute);
    my $openingHours = getOpeningHours($branchcode, $dt);
    return 1 if ($openingHours->[0] le $hm && $hm lt $openingHours->[1]);
    return undef;
}

=head2 getOpeningHours

Gets opening hours for the given branchcode. Opening hours are an array of
weekdays, with arrays of start time and ending time

@PARAM1 String, branchcode
@PARAM2 DateTime, OPTIONAL weekday to check for openness. Defaults to current time | now()
@RETURNS ARRAYRef of HH:MM, ex.
        [
          '12:22', #opening time
          '22:00', #closing time
        ]

@THROWS from _getOpeningHoursFromSyspref()

=cut

sub getOpeningHours {
    my ($branchcode, $dt) = @_;
    #Should cache the syspref de-yaml-ization, but no Koha::Cache here yet.

    $dt = DateTime->now(time_zone => C4::Context->tz()) unless $dt;
    my $openingHours = _getOpeningHoursFromSyspref();
    my $branchOpeningHours = $openingHours->{$branchcode};
    Koha::Exception::FeatureUnavailable->throw(error => "System preference 'OpeningHours' is missing opening hours for branch '$branchcode'")
        unless $branchOpeningHours;

                                                #Array starts from 0, DateTime->day_of_week start from 1
    my $dailyOpeningHours = $branchOpeningHours->[ $dt->day_of_week()-1 ];
    Koha::Exception::FeatureUnavailable->throw(error => "System preference 'OpeningHours' is missing opening hours for branch '$branchcode' and weekday '".$dt->day_of_week()."'")
        unless $dailyOpeningHours;

    return $dailyOpeningHours;
}

=head2 _getOpeningHoursFromSyspref

@DEPRECATED use Bug 17015 when it comes out

@RETURNS HASHRef of ARRAYRef of ARRAYRef of HH:MM, ex.
  {
    CPL => [
      ['12:22', #opening time
       '22:00', #closing time
      ],
      ['12:23',
       '21:30',
      ],
      ...
    ],
    FPL => [
      ...
    ],
    ...
  }

@THROWS Koha::Exception::FeatureUnavailable if syspref "OpeningHours" is not properly set

=cut

sub _getOpeningHoursFromSyspref {
    my $logger = Koha::Logger->get({category => __PACKAGE__});
    my $sp = C4::Context->preference('OpeningHours');
    Koha::Exception::NoSystemPreference->throw(error => 'System preference "OpeningHours" not set. Cannot get opening hours!')
        unless $sp;
    eval {
        $sp = YAML::XS::Load( $sp );
    };
    Koha::Exception::BadSystemPreference->throw(error => 'System preference "OpeningHours" is not valid YAML. Validate it using yamllint! or '.$@)
        if $@;
    $logger->debug("'OpeningHours'-syspref: ".Data::Dumper::Dumper($sp)) if $logger->is_debug;
    return $sp;
}

=head3 type

=cut

sub _type {
    return 'Branch';
}

sub object_class {
    return 'Koha::Library';
}

1;
