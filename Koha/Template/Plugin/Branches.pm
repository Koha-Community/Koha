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
    my $dbh = C4::Context->dbh;
    my @params;
    my $query = q|
        SELECT branchcode, branchname
        FROM branches
    |;
    if (    C4::Branch::onlymine
        and C4::Context->userenv
        and C4::Context->userenv->{branch} )
    {
        $query .= q| WHERE branchcode = ? |;
        push @params, C4::Context->userenv->{branch};
    }
    $query .= q| ORDER BY branchname|;
    my $branches = $dbh->selectall_arrayref( $query, { Slice => {} }, @params );

    if ( $selected ) {
        for my $branch ( @$branches ) {
            if ( $branch->{branchcode} eq $selected ) {
                $branch->{selected} = 1;
            }
        }
    }
    return $branches;
}

1;
