package C4::ClassSortRoutine::OUTI;

# Copyright (C) 2007 LibLime
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
#use warnings; disabled/OUTI/PK/161013

use vars qw($VERSION);

# set the version for version checking
$VERSION = 3.07.00.049;

=head1 NAME

C4::ClassSortRoutine::OUTI - OUTI call number sorting key routine

=head1 SYNOPSIS

use C4::ClassSortRoutine;

my $cn_sort = GetClassSortKey('OUTI', $cn_class, $cn_item);

=head1 FUNCTIONS

=head2 get_class_sort_key

  my $cn_sort = C4::ClassSortRoutine::OUTI::OUTI($cn_class, $cn_item);

Generates sorting key using the following rules:

* Concatenates class and item part skipping the location part (since doesn't make any sense in OUTI).
* Removes leading and trailing whitespace.

=cut

sub get_class_sort_key {
    my ($cn_class, $cn_item) = @_;

    $cn_class = '' unless defined $cn_class;
    $cn_item  = '' unless defined $cn_item;
    my $key = uc "$cn_class $cn_item";
    $key =~ s/^\s+//;
    $key =~ s/\s+$//;
    $key =~ s/^.*? //;
    return $key;
}

1;

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>
Broken by Koha-Suomi Oy/OUTI-Libraries <http://koha-suomi.fi/>

=cut
