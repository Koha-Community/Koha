package C4::ClassSortRoutine::Dewey;

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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use warnings;

use vars qw($VERSION);

# set the version for version checking
$VERSION = 3.00;

=head1 NAME 

C4::ClassSortRoutine::Dewey - generic call number sorting key routine

=head1 SYNOPSIS

use C4::ClassSortRoutine;

my $cn_sort = GetClassSortKey('Dewey', $cn_class, $cn_item);

=head1 FUNCTIONS

=head2 get_class_sort_key

  my $cn_sort = C4::ClassSortRoutine::Dewey::Dewey($cn_class, $cn_item);

Generates sorting key using the following rules:

* Concatenates class and item part.
* Converts to uppercase.
* Removes leading and trailing whitespace and '/'
* Separates alphabetic prefix from the rest of the call number
* Splits into tokens on whitespaces and periods.
* Leaves first digit group as is.
* Converts second digit group to 15-digit long group, padded on right with zeroes.
* Converts each run of whitespace to an underscore.
* Removes any remaining non-alphabetical, non-numeric, non-underscore characters.

=cut

sub get_class_sort_key {
    my ($cn_class, $cn_item) = @_;

    $cn_class = '' unless defined $cn_class;
    $cn_item  = '' unless defined $cn_item;
    my $init = uc "$cn_class $cn_item";
    $init =~ s/^\s+//;
    $init =~ s/\s+$//;
    $init =~ s!/!!g;
    $init =~ s/^([\p{IsAlpha}]+)/$1 /;
    my @tokens = split /\.|\s+/, $init;
    my $digit_group_count = 0;
    for (my $i = 0; $i <= $#tokens; $i++) {
        if ($tokens[$i] =~ /^\d+$/) {
            $digit_group_count++;
            if (2 == $digit_group_count) {
                $tokens[$i] = sprintf("%-15.15s", $tokens[$i]);
                $tokens[$i] =~ tr/ /0/;
            }
        }
    }
    my $key = join("_", @tokens);
    $key =~ s/[^\p{IsAlnum}_]//g;

    return $key;

}

1;

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut

