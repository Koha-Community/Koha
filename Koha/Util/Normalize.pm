package Koha::Util::Normalize;

# Copyright 2016 Koha Development Team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use parent qw( Exporter );

our @EXPORT = qw(
    legacy_default
    remove_spaces
    upper_case
    lower_case
    ISBN
);

=head1 NAME

Koha::Util::Normalize - utility class with string normalization routines

=head1 METHODS

=head2 legacy_default

Default normalization function

=cut

sub legacy_default {
    my ($string) = @_;
    return if !defined($string);

    $string = uc $string;

    $string =~ s/[.;:,\]\[\)\(\/'"]//g;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    $string =~ s/\s+/ /g;

    return $string;
}

=head2 remove_spaces

Normalization function removing spaces

=cut

sub remove_spaces {
    my ($string) = @_;
    return if !defined($string);

    $string =~ s/\s+//g;

    return $string;
}

=head2 upper_case

Normalization function converting characters into upper-case

=cut

sub upper_case {
    my ($string) = @_;
    return if !defined($string);

    $string = uc $string;

    return $string;
}

=head2 lower_case

Normalization function converting characters into lower-case

=cut

sub lower_case {
    my ($string) = @_;
    return if !defined($string);

    $string = lc $string;

    return $string;
}

=head2 ISBN

Normalization function converting ISBN strings to ISBN13
If string is not a valid ISBN we pass it through unaltered

=cut

sub ISBN {
    my ($string) = @_;
    return if !defined($string);

    my $isbn = C4::Koha::NormalizeISBN(
        {
            isbn           => $string,
            format         => 'ISBN-13',
            strip_hyphens  => 1,
            return_invalid => 1,
        }
    );

    return $isbn;
}

1;
__END__

=head1 AUTHOR

Koha Development Team <https://koha-community.org/>

Tomas Cohen Arazi <tomascohen@theke.io>

=cut
