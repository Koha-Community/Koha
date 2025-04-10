package C4::ClassSortRoutine;

# Copyright 2022 Koha Development Team
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

use Class::Factory::Util;

our ( @ISA, @EXPORT_OK );

BEGIN {
    require Exporter;
    @ISA       = qw(Exporter);
    @EXPORT_OK = qw(
        GetSortRoutineNames
        GetClassSortKey
    );
}

=head1 NAME 

C4::ClassSortRoutine - base object for creation of classification sorting
                       key generation routines

=head1 SYNOPSIS

use C4::ClassSortRoutine;

=head1 FUNCTIONS

=cut

# initialization code
my %loaded_routines = ();
my @sort_routines   = GetSortRoutineNames();
foreach my $sort_routine (@sort_routines) {
    if ( eval "require C4::ClassSortRoutine::$sort_routine" ) {
        my $ref;
        $ref = \&{"C4::ClassSortRoutine::${sort_routine}::get_class_sort_key"};
        if ( eval { $ref->( "a", "b" ) } ) {
            $loaded_routines{$sort_routine} = $ref;
        } else {
            $loaded_routines{$sort_routine} = \&_get_class_sort_key;
        }
    } else {
        $loaded_routines{$sort_routine} = \&_get_class_sort_key;
    }
}

=head2 GetSortRoutineNames

  my @routines = GetSortRoutineNames();

Get names of all modules under C4::ClassSortRoutine::*.  Adding
a new classification sorting routine can therefore be done 
simply by writing a new submodule under C4::ClassSortRoutine and
placing it in the C4/ClassSortRoutine directory.

=cut

sub GetSortRoutineNames {
    return C4::ClassSortRoutine->subclasses();
}

=head2  GetClassSortKey

  my $cn_sort = GetClassSortKey($sort_routine, $cn_class, $cn_item);

Generates classification sorting key.  If $sort_routine does not point
to a valid submodule in C4::ClassSortRoutine, default to a basic
normalization routine.

=cut

sub GetClassSortKey {
    my ( $sort_routine, $cn_class, $cn_item ) = @_;
    unless ( exists $loaded_routines{$sort_routine} ) {
        warn "attempting to use non-existent class sorting routine $sort_routine\n";
        $loaded_routines{$sort_routine} = \&_get_class_sort_key;
    }
    my $key = $loaded_routines{$sort_routine}->( $cn_class, $cn_item );

    # FIXME -- hardcoded length for cn_sort
    # should replace with some way of getting column widths from
    # the DB schema -- since doing this should ideally be
    # independent of the DBMS, deferring for the moment.
    return substr( $key, 0, 255 );
}

=head2 _get_class_sort_key 

Basic sorting function.  Concatenates classification part 
and item, converts to uppercase, changes each run of
whitespace to '_', and removes any non-digit, non-latin
letter characters.

=cut

sub _get_class_sort_key {
    my ( $cn_class, $cn_item ) = @_;
    my $key = uc "$cn_class $cn_item";
    $key =~ s/\s+/_/;
    $key =~ s/[^A-Z_0-9]//g;
    return $key;
}

1;

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut

