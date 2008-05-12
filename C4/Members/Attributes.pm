package C4::Members::Attributes;

# Copyright (C) 2008 LibLime
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
use C4::Context;
use C4::Members::AttributeTypes;

use vars qw($VERSION);

BEGIN {
    # set the version for version checking
    $VERSION = 3.00;
}

=head1 NAME

C4::Members::Attribute - manage extend patron attributes

=head1 SYNOPSIS

=over 4

my $attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber);

=back

=head1 FUNCTIONS

=head2 GetBorrowerAttributes

=over 4

my $attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber[, $opac_only]);

=back

Retrieve an arrayref of extended attributes associated with the
patron specified by C<$borrowernumber>.  Each entry in the arrayref
is a hashref containing the following keys:

code (attribute type code)
description (attribute type description)
value (attribute value)
value_description (attribute value description (if associated with an authorised value))
password (password, if any, associated with attribute

If the C<$opac_only> parameter is present and has a true value, only the attributes
marked for OPAC display are returned.

=cut

sub GetBorrowerAttributes {
    my $borrowernumber = shift;
    my $opac_only = @_ ? shift : 0;

    my $dbh = C4::Context->dbh();
    my $query = "SELECT code, description, attribute, lib, password
                 FROM borrower_attributes
                 JOIN borrower_attribute_types USING (code)
                 LEFT JOIN authorised_values ON (category = authorised_value_category AND attribute = authorised_value)
                 WHERE borrowernumber = ?";
    $query .= "\nAND opac_display = 1" if $opac_only;
    $query .= "\nORDER BY code, attribute";
    my $sth = $dbh->prepare_cached($query);
    $sth->execute($borrowernumber);
    my @results = ();
    while (my $row = $sth->fetchrow_hashref()) {
        push @results, {
            code              => $row->{'code'},
            description       => $row->{'description'},
            value             => $row->{'attribute'},  
            value_description => $row->{'lib'},  
            password          => $row->{'password'},
        }
    }
    return \@results;
}

=head2 CheckUniqueness

=over 4

my $ok = CheckUniqueness($code, $value[, $borrowernumber]);

=back

Given an attribute type and value, verify if would violate
a unique_id restriction if added to the patron.  The
optional C<$borrowernumber> is the patron that the attribute
value would be added to, if known.

Returns false if the C<$code> is not valid or the
value would violate the uniqueness constraint.

=cut

sub CheckUniqueness {
    my $code = shift;
    my $value = shift;
    my $borrowernumber = @_ ? shift : undef;

    my $attr_type = C4::Members::AttributeTypes->fetch($code);

    return 0 unless defined $attr_type;
    return 1 unless $attr_type->unique_id();

    my $dbh = C4::Context->dbh;
    my $sth;
    if (defined($borrowernumber)) {
        $sth = $dbh->prepare("SELECT COUNT(*) 
                              FROM borrower_attributes 
                              WHERE code = ? 
                              AND attribute = ?
                              AND borrowernumber <> ?");
        $sth->execute($code, $value, $borrowernumber);
    } else {
        $sth = $dbh->prepare("SELECT COUNT(*) 
                              FROM borrower_attributes 
                              WHERE code = ? 
                              AND attribute = ?");
        $sth->execute($code, $value);
    }
    my ($count) = $sth->fetchrow_array;
    $sth->finish();
    return ($count == 0);
}

=head2 SetBorrowerAttributes 

=over 4

SetBorrowerAttributes($borrowernumber, [ { code => 'CODE', value => 'value', password => 'password' }, ... ] );

=back

Set patron attributes for the patron identified by C<$borrowernumber>,
replacing any that existed previously.

=cut

sub SetBorrowerAttributes {
    my $borrowernumber = shift;
    my $attr_list = shift;

    my $dbh = C4::Context->dbh;
    my $delsth = $dbh->prepare("DELETE FROM borrower_attributes WHERE borrowernumber = ?");
    $delsth->execute($borrowernumber);

    my $sth = $dbh->prepare("INSERT INTO borrower_attributes (borrowernumber, code, attribute, password)
                             VALUES (?, ?, ?, ?)");
    foreach my $attr (@$attr_list) {
        $attr->{password} = undef unless exists $attr->{password};
        $sth->execute($borrowernumber, $attr->{code}, $attr->{value}, $attr->{password});
    }
}

=head1 AUTHOR

Koha Development Team <info@koha.org>

Galen Charlton <galen.charlton@liblime.com>

=cut

1;
