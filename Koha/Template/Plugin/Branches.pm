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

    my $query = "SELECT branchname FROM branches WHERE branchcode = ?";
    my $sth   = C4::Context->dbh->prepare($query);
    $sth->execute($branchcode);
    my $b = $sth->fetchrow_hashref();
    return $b ? $b->{'branchname'} : q{};
}

sub GetLoggedInBranchcode {
    my ($self) = @_;

    return C4::Context->userenv ?
        C4::Context->userenv->{'branch'} :
        '';
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
    my $unfiltered = $params->{unfiltered} || 0;
    my $search_params = $params->{search_params} || {};

    if ( !$unfiltered ) {
        $search_params->{only_from_group} = $params->{only_from_group} || 0;
    }

    my $libraries = $unfiltered
      ? Koha::Libraries->search( $search_params, { order_by => ['branchname'] } )->unblessed
      : Koha::Libraries->search_filtered( $search_params, { order_by => ['branchname'] } )->unblessed;

    for my $l ( @$libraries ) {
        if (       defined $selected and $l->{branchcode} eq $selected
            or not defined $selected and C4::Context->userenv and $l->{branchcode} eq ( C4::Context->userenv->{branch} // q{} )
        ) {
            $l->{selected} = 1;
        }
    }

    return $libraries;
}

sub InIndependentBranchesMode {
    my ( $self ) = @_;
    return ( not C4::Context->preference("IndependentBranches") or C4::Context::IsSuperLibrarian );
}

1;
