package C4::Branch;

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
#use warnings; FIXME - Bug 2505
require Exporter;
use C4::Context;
use Koha::LibraryCategories;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		&GetBranchName
		&GetBranch
		&GetBranches
		&GetBranchesLoop
		&mybranch
	);
    @EXPORT_OK = qw( &onlymine &mybranch );
}

=head1 NAME

C4::Branch - Koha branch module

=head1 SYNOPSIS

use C4::Branch;

=head1 DESCRIPTION

The functions in this module deal with branches.

=head1 FUNCTIONS

=head2 GetBranches

  $branches = &GetBranches();

Returns informations about ALL branches, IndependentBranches Insensitive.

Create a branch selector with the following code.

=head3 in PERL SCRIPT

    my $branches = GetBranches;
    my @branchloop;
    foreach my $thisbranch (sort keys %$branches) {
        my $selected = 1 if $thisbranch eq $branch;
        my %row =(value => $thisbranch,
                    selected => $selected,
                    branchname => $branches->{$thisbranch}->{branchname},
                );
        push @branchloop, \%row;
    }

=head3 in TEMPLATE

    <select name="branch" id="branch">
        <option value=""></option>
            [% FOREACH branchloo IN branchloop %]
                [% IF ( branchloo.selected ) %]
                    <option value="[% branchloo.value %]" selected="selected">[% branchloo.branchname %]</option>
                [% ELSE %]
                    <option value="[% branchloo.value %]" >[% branchloo.branchname %]</option>
                [% END %]
            [% END %]
    </select>

=head4 Note that you often will want to just use GetBranchesLoop, for exactly the example above.

=cut

sub GetBranches {
    my ($onlymine) = @_;

    # returns a reference to a hash of references to ALL branches...
    my %branches;
    my $dbh = C4::Context->dbh;
    my $sth;
    my $query = "SELECT * FROM branches";
    my @bind_parameters;
    if ( $onlymine && C4::Context->userenv && C4::Context->userenv->{branch} ) {
        $query .= ' WHERE branchcode = ? ';
        push @bind_parameters, C4::Context->userenv->{branch};
    }
    $query .= " ORDER BY branchname";
    $sth = $dbh->prepare($query);
    $sth->execute(@bind_parameters);

    my $relations_sth =
      $dbh->prepare("SELECT branchcode,categorycode FROM branchrelations");
    $relations_sth->execute();
    my %relations;
    while ( my $rel = $relations_sth->fetchrow_hashref ) {
        push @{ $relations{ $rel->{branchcode} } }, $rel->{categorycode};
    }

    while ( my $branch = $sth->fetchrow_hashref ) {
        foreach my $cat ( @{ $relations{ $branch->{branchcode} } } ) {
            $branch->{category}{$cat} = 1;
        }
        $branches{ $branch->{'branchcode'} } = $branch;
    }
    return ( \%branches );
}

sub onlymine {
    return
         C4::Context->preference('IndependentBranches')
      && C4::Context->userenv
      && !C4::Context->IsSuperLibrarian()
      && C4::Context->userenv->{branch};
}

# always returns a string for OK comparison via "eq" or "ne"
sub mybranch {
    C4::Context->userenv           or return '';
    return C4::Context->userenv->{branch} || '';
}

sub GetBranchesLoop {  # since this is what most pages want anyway
    my $branch   = @_ ? shift : mybranch();     # optional first argument is branchcode of "my branch", if preselection is wanted.
    my $onlymine = @_ ? shift : onlymine();
    my $branches = GetBranches($onlymine);
    my @loop;
    foreach my $branchcode ( sort { uc($branches->{$a}->{branchname}) cmp uc($branches->{$b}->{branchname}) } keys %$branches ) {
        push @loop, {
            value      => $branchcode,
            branchcode => $branchcode,
            selected   => ($branchcode eq $branch) ? 1 : 0,
            branchname => $branches->{$branchcode}->{branchname},
        };
    }
    return \@loop;
}

=head2 GetBranchName

=cut

sub GetBranchName {
    my ($branchcode) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    $sth = $dbh->prepare("Select branchname from branches where branchcode=?");
    $sth->execute($branchcode);
    my $branchname = $sth->fetchrow_array;
    return ($branchname);
}

=head2 GetBranch

$branch = GetBranch( $query, $branches );

=cut

sub GetBranch {
    my ( $query, $branches ) = @_;    # get branch for this query from branches
    my $branch = $query->param('branch');
    my %cookie = $query->cookie('userenv');
    ($branch)                || ($branch = $cookie{'branchname'});
    ( $branches->{$branch} ) || ( $branch = ( keys %$branches )[0] );
    return $branch;
}

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
