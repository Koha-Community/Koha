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

use Modern::Perl;
use Scalar::Util qw(blessed);

use Email::Valid;
use DateTime;

use C4::Context;
use C4::Biblio;

use Koha::Exception::BadParameter;
use Koha::Exception::SubroutineCall;

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

my ($f, $sf);
sub getMARCSubfieldSelectorCache {
    return $sf;
}
sub getMARCFieldSelectorCache {
    return $f;
}
sub getMARCSelectorCache {
    return {f => $f, sf => $sf};
}

=HEAD2 tries

Same as use_validator except wraps exceptions as Exceptions
See tests in t/Koha/Validation.t for usage examples.

    my $ok = Koha::Validation->tries('key', ['koha@example.com', 'this@example.com'], 'email', 'a');
    try {
        Koha::Validation->tries('key', 'kohaexamplecom', 'email');
    } catch {
        print $_->message;
    };

@PARAM1 String, human readable key for the value we are validating
@PARAM2 Variable, variable to be validated. Can be an array or hash or a scalar
@PARAM3 String, validator selector, eg. email, phone, marcSubfieldSelector, ...
@PARAM4 String, the expected nested data types.
                For example 'aa' is a Array of arrays
                'h' is a hash
                'ah' is a array of hashes
@RETURNS 1 if everything validated ok
@THROWS Koha::Exception::BadParameter typically. See individual validator functions for Exception type specifics

=cut

sub tries {
    my ($package, $key, $val, $validator, $types) = @_;
    Koha::Exception::SubroutineCall->throw(error => _errmsg('','','You must use the object notation \'->\' instead of \'::\' to invoke me!')) unless __PACKAGE__ eq $package;

    if ($types) {
        my $t = 'v_'.substr($types,0,1); #Get first char
        $package->$t($key, $val, $validator, substr($types,1)); #Trim first char from types
    }
    else {
        $validator = 'v_'.$validator;
        my $err = __PACKAGE__->$validator($val);
        Koha::Exception::BadParameter->throw(error => _errmsg($key, $val, $err)) if $err;
        return 1;
    }
    return 1;
}

sub v_a {
    my ($package, $key, $val, $validator, $types) = @_;
    Koha::Exception::BadParameter->throw(error => _errmsg($key, $val, 'is not an \'ARRAY\'')) unless (ref($val) eq 'ARRAY');

    if ($types) {
        for (my $i=0 ; $i<@$val ; $i++) {
            my $v = $val->[$i];
            my $t = 'v_'.substr($types,0,1); #Get first char
            $package->$t($key.'->'.$i, $v, $validator, substr($types,1)); #Trim first char from types
        }
    }
    else {
        for (my $i=0 ; $i<@$val ; $i++) {
            my $v = $val->[$i];
            $package->tries($key.'->'.$i, $v, $validator, $types);
        }
    }
}
sub v_h {
    my ($package, $key, $val, $validator, $types) = @_;
    Koha::Exception::BadParameter->throw(error => _errmsg($key, $val, 'is not a \'HASH\'')) unless (ref($val) eq 'HASH');

    if ($types) {
        while(my ($k, $v) = each(%$val)) {
            my $t = 'v_'.substr($types,0,1); #Get first char
            $package->$t($key.'->'.$k, $v, $validator, substr($types,1)); #Trim first char from types
        }
    }
    else {
        while(my ($k, $v) = each(%$val)) {
            $package->tries($key.'->'.$k, $v, $validator, $types);
        }
    }
}
sub v_email {
    my ($package, $val) = @_;

    return 'is not a valid \'email\'' if (not defined Email::Valid->address($val));
    return undef;
}
sub v_DateTime {
    my ($package, $val) = @_;

    return 'is undef' unless($val);
    return 'is not blessed' unless(blessed($val));
    return 'is not a valid \'DateTime\'' unless ($val->isa('DateTime'));
    return undef;
}
sub v_digit {
    my ($package, $val) = @_;

    return 'is not a valid \'digit\'' unless ($val =~ /^-?\d+$/);
    return 'negative numbers are not a \'digit\'' if $val < 0;
    return undef;
}
sub v_double {
    my ($package, $val) = @_;

    return 'is not a valid \'double\'' unless ($val =~ /^\d+\.?\d*$/);
    return undef;
}
sub v_string {
    my ($package, $val) = @_;

    return 'is not a valid \'string\', but undefined' unless(defined($val));
    return 'is not a valid \'string\', but zero length' if(length($val) == 0);
    return 'is not a valid \'string\', but a char' if(length($val) == 1);
    return undef;
}
sub v_phone {
    my ($package, $val) = @_;

    my $regex = C4::Context->preference("ValidatePhoneNumber");
    return 'is not a valid \'phonenumber\'' if ($val !~ /$regex/);
    return undef;
}

=head2 marcSubfieldSelector

See marcSelector()

=cut

sub v_marcSubfieldSelector {
    my ($package, $val) = @_;

    if ($val =~ /^([0-9.]{3})(\w)$/) {
        ($f, $sf) = ($1, $2);
        return undef;
    }
    ($f, $sf) = (undef, undef);
    return 'is not a MARC subfield selector';
}

=head2 marcFieldSelector

See marcSelector()

=cut

sub v_marcFieldSelector {
    my ($package, $val) = @_;

    if ($val =~ /^([0-9.]{3})$/) {
        ($f, $sf) = ($1, undef);
        return undef;
    }
    ($f, $sf) = (undef, undef);
    return 'is not a MARC field selector';
}

=head2 marcSelector

Sets package variables
$__PACKAGE__::f    = MARC field code
$__PACKAGE__::sf   = MARC subfield code
if a correct MARC selector was found
for ease of access
The existing variables are overwritten when a new validation check is done.

Access them using getMARCSubfieldSelectorCache() and getMARCFieldSelectorCache()

marcSelector can also deal with any value in KohaToMARCMapping.
marcSubfieldSelector() and marcFieldSelector() deal with MARC-tags only

@PARAM1, String, current package
@PARAM2, String, MARC selector, eg. 856u or 110

=cut

sub v_marcSelector {
    my ($package, $val) = @_;

    if ($val =~ /^([0-9.]{3})(\w*)$/) {
        ($f, $sf) = ($1, $2);
       return undef;
    }
    ($f, $sf) = C4::Biblio::GetMarcFromKohaField($val, '');
    return 'is not a MARC selector' unless ($f && $sf);
    return undef;
}

sub _errmsg {
    my ($key, $val, $err) = @_;

    #Find the first call from outside this package
    my @cc; my $i = 0;
    do {
        @cc = caller($i++);
    } while ($cc[0] eq __PACKAGE__);

    return $cc[3]."() '$key' => '$val' $err\n    at ".$cc[0].':'.$cc[2];
}

1;
