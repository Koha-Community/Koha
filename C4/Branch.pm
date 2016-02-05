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

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		&GetBranch
	);
    @EXPORT_OK = qw( &onlymine );
}

=head1 NAME

C4::Branch - Koha branch module

=head1 SYNOPSIS

use C4::Branch;

=head1 DESCRIPTION

The functions in this module deal with branches.

=head1 FUNCTIONS

=cut

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
