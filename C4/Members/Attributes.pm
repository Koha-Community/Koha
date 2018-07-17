package C4::Members::Attributes;

# Copyright (C) 2008 LibLime
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

use strict;
use warnings;

use Text::CSV;      # Don't be tempted to use Text::CSV::Unicode -- even in binary mode it fails.
use C4::Context;

use Koha::Patron::Attribute::Types;

use vars qw(@ISA @EXPORT_OK @EXPORT %EXPORT_TAGS);
our ($csv, $AttributeTypes);

BEGIN {
    @ISA = qw(Exporter);
    @EXPORT_OK = qw(
                    extended_attributes_code_value_arrayref
                    );
    %EXPORT_TAGS = ( all => \@EXPORT_OK );
}

=head1 NAME

C4::Members::Attributes - manage extend patron attributes

=head1 SYNOPSIS

  use C4::Members::Attributes;

=head1 FUNCTIONS

=head2 extended_attributes_code_value_arrayref 

   my $patron_attributes = "homeroom:1150605,grade:01,extradata:foobar";
   my $aref = extended_attributes_code_value_arrayref($patron_attributes);

Takes a comma-delimited CSV-style string argument and returns the kind of data structure that Koha::Patron->extended_attributes wants,
namely a reference to array of hashrefs like:
 [ { code => 'CODE', attribute => 'value' }, { code => 'CODE2', attribute => 'othervalue' } ... ]

Caches Text::CSV parser object for efficiency.

=cut

sub extended_attributes_code_value_arrayref {
    my $string = shift or return;
    use Data::Printer colored => 1; warn p $string;
    $csv or $csv = Text::CSV->new({binary => 1});  # binary needed for non-ASCII Unicode
    my $ok   = $csv->parse($string);  # parse field again to get subfields!
    my @list = $csv->fields();
    # TODO: error handling (check $ok)
    return [
        sort {&_sort_by_code($a,$b)}
        map { map { my @arr = split /:/, $_, 2; { code => $arr[0], attribute => $arr[1] } } $_ }
        @list
    ];
    # nested map because of split
}

sub _sort_by_code {
    my ($x, $y) = @_;
    defined ($x->{code}) or return -1;
    defined ($y->{code}) or return 1;
    return $x->{code} cmp $y->{code} || $x->{value} cmp $y->{value};
}

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Galen Charlton <galen.charlton@liblime.com>

=cut

1;
