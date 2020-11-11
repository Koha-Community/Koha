package Koha::Template::Plugin::Branches;

# Copyright ByWater Solutions 2012
# Copyright BibLibre 2014

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

use Template::Plugin;
use base qw( Template::Plugin );

use C4::Koha;
use C4::Context;
use Koha::Libraries;

sub GetName {
    my ( $self, $branchcode ) = @_;

    my $l = Koha::Libraries->find($branchcode);
    return $l ? $l->branchname : q{};
}

sub GetLoggedInBranchcode {
    my ($self) = @_;

    return C4::Context::mybranch;
}

sub GetLoggedInBranchname {
    my ($self) = @_;

    return C4::Context->userenv ? C4::Context->userenv->{'branchname'} : q{};
}

sub GetURL {
    my ( $self, $branchcode ) = @_;

    my $query = "SELECT branchurl FROM branches WHERE branchcode = ?";
    my $sth   = C4::Context->dbh->prepare($query);
    $sth->execute($branchcode);
    my $b = $sth->fetchrow_hashref();
    return $b->{branchurl};
}

sub all {
    my ( $self, $params ) = @_;
    my $selected = $params->{selected};
    my $selecteds = $params->{selecteds};
    my $unfiltered = $params->{unfiltered} || 0;
    my $search_params = $params->{search_params} || {};

    if ( !$unfiltered ) {
        $search_params->{only_from_group} = $params->{only_from_group} || 0;
    }

    my $libraries = $unfiltered
      ? Koha::Libraries->search( $search_params, { order_by => ['branchname'] } )->unblessed
      : Koha::Libraries->search_filtered( $search_params, { order_by => ['branchname'] } )->unblessed;

    if (defined $selecteds) {
        # For a select multiple, must be a Koha::Libraries
        my @selected_branchcodes = $selecteds ? $selecteds->get_column( ['branchcode'] ) : ();
        $libraries = [ map {
            my $l = $_;
            $l->{selected} = 1
              if grep { $_ eq $l->{branchcode} } @selected_branchcodes;
            $l;
        } @$libraries ];
    }
    else {
        for my $l ( @$libraries ) {
            if (       defined $selected and $l->{branchcode} eq $selected
                or not defined $selected and C4::Context->userenv and $l->{branchcode} eq ( C4::Context->userenv->{branch} // q{} )
            ) {
                $l->{selected} = 1;
            }
        }
    }

    return $libraries;
}

sub InIndependentBranchesMode {
    my ( $self ) = @_;
    return ( not C4::Context->preference("IndependentBranches") or C4::Context::IsSuperLibrarian );
}

sub pickup_locations {
    my ( $self, $params ) = @_;
    my $search_params = $params->{search_params} || {};
    my $selected      = $params->{selected};
    my @libraries;

    if(defined $search_params->{item} || defined $search_params->{biblio}) {
        my $item = $search_params->{'item'};
        my $biblio = $search_params->{'biblio'};
        my $patron = $search_params->{'patron'};

        unless (! defined $patron || ref($patron) eq 'Koha::Patron') {
            $patron = Koha::Patrons->find($patron);
        }

        if ($item) {
            $item = Koha::Items->find($item)
              unless ref($item) eq 'Koha::Item';
            @libraries = $item->pickup_locations( { patron => $patron } )
              if defined $item;
        }
        elsif ($biblio) {
            $biblio = Koha::Biblios->find($biblio)
              unless ref($biblio) eq 'Koha::Biblio';
            @libraries = @{ $biblio->pickup_locations( { patron => $patron } ) }
              if defined $biblio;
        }
    }

    @libraries = Koha::Libraries->search( { pickup_location => 1 },
        { order_by => ['branchname'] } )->as_list
      unless @libraries;

    @libraries = map { $_->unblessed } @libraries;

    for my $l (@libraries) {
        if ( defined $selected and $l->{branchcode} eq $selected
            or not defined $selected
            and C4::Context->userenv
            and $l->{branchcode} eq C4::Context->userenv->{branch} )
        {
            $l->{selected} = 1;
        }
    }

    return \@libraries;
}

1;
