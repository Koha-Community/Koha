package Koha::Validation;

# Copyright 2017 Koha-Suomi Oy
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

use Modern::Perl;

use C4::Context;
use Email::Valid;

=head1 NAME

Koha::Validation - validates inputs

=head1 SYNOPSIS

  use Koha::Validation

=head1 DESCRIPTION

This module lets you validate given inputs.

=head2 METHODS

=head3 email

Koha::Validation::email("email@address.com");
Koha::Validation->email("email@address.com");

Validates given email.

returns: 1 if the given email is valid (or empty), 0 otherwise.

=cut

sub email {
    my $address = shift;
    $address = shift if $address eq __PACKAGE__;

    return 1 unless $address;
    return 0 if $address =~ /(^(\s))|((\s)$)/;

    return (not defined Email::Valid->address($address)) ? 0:1;
}

=head3 phone

Koha::Validation::validate_phonenumber(123456789);
Koha::Validation->validate_phonenumber(123456789);

Validates given phone number.

returns: 1 if the given phone number is valid (or empty), 0 otherwise.

=cut

sub phone {
    my $phonenumber = shift;
    $phonenumber = shift if $phonenumber eq __PACKAGE__;

    return 1 unless $phonenumber;
    return 0 if $phonenumber =~ /(^(\s))|((\s)$)/;

    my $regex = C4::Context->preference("ValidatePhoneNumber");
    $regex = qr/$regex/;

    return ($phonenumber !~ /$regex/) ? 0:1;
}

1;
