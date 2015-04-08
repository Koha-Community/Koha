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
use C4::Members::AttributeTypes;

use vars qw($VERSION @ISA @EXPORT_OK @EXPORT %EXPORT_TAGS);
our ($csv, $AttributeTypes);

BEGIN {
    # set the version for version checking
    $VERSION = 3.07.00.049;
    @ISA = qw(Exporter);
    @EXPORT_OK = qw(GetBorrowerAttributes GetBorrowerAttributeValue CheckUniqueness SetBorrowerAttributes
                    DeleteBorrowerAttribute UpdateBorrowerAttribute
                    extended_attributes_code_value_arrayref extended_attributes_merge
                    SearchIdMatchingAttribute);
    %EXPORT_TAGS = ( all => \@EXPORT_OK );
}

=head1 NAME

C4::Members::Attributes - manage extend patron attributes

=head1 SYNOPSIS

  use C4::Members::Attributes;
  my $attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber);

=head1 FUNCTIONS

=head2 GetBorrowerAttributes

  my $attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber[, $opac_only]);

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
    my $branch_limit = @_ ? shift : 0;

    my $dbh = C4::Context->dbh();
    my $query = "SELECT code, description, attribute, lib, password, display_checkout, category_code, class
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
            display_checkout  => $row->{'display_checkout'},
            category_code     => $row->{'category_code'},
            class             => $row->{'class'},
        }
    }
    $sth->finish;
    return \@results;
}

=head2 GetAttributes

  my $attributes = C4::Members::Attributes::GetAttributes([$opac_only]);

Retrieve an arrayref of extended attribute codes

=cut

sub GetAttributes {
    my ($opac_only) = @_;

    my $dbh = C4::Context->dbh();
    my $query = "SELECT code FROM borrower_attribute_types";
    $query .= "\nWHERE opac_display = 1" if $opac_only;
    $query .= "\nORDER BY code";
    return $dbh->selectcol_arrayref($query);
}

=head2 GetBorrowerAttributeValue

  my $value = C4::Members::Attributes::GetBorrowerAttributeValue($borrowernumber, $attribute_code);

Retrieve the value of an extended attribute C<$attribute_code> associated with the
patron specified by C<$borrowernumber>.

=cut

sub GetBorrowerAttributeValue {
    my $borrowernumber = shift;
    my $code = shift;

    my $dbh = C4::Context->dbh();
    my $query = "SELECT attribute
                 FROM borrower_attributes
                 WHERE borrowernumber = ?
                 AND code = ?";
    my $value = $dbh->selectrow_array($query, undef, $borrowernumber, $code);
    return $value;
}

=head2 SearchIdMatchingAttribute

  my $matching_borrowernumbers = C4::Members::Attributes::SearchIdMatchingAttribute($filter);

=cut

sub SearchIdMatchingAttribute{
    my $filter = shift;
    $filter = [$filter] unless ref $filter;

    my $dbh   = C4::Context->dbh();
    my $query = qq{
SELECT DISTINCT borrowernumber
FROM borrower_attributes
JOIN borrower_attribute_types USING (code)
WHERE staff_searchable = 1
AND (} . join (" OR ", map "attribute like ?", @$filter) .qq{)};
    my $sth = $dbh->prepare_cached($query);
    $sth->execute(map "%$_%", @$filter);
    return [map $_->[0], @{ $sth->fetchall_arrayref }];
}

=head2 CheckUniqueness

  my $ok = CheckUniqueness($code, $value[, $borrowernumber]);

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
    return ($count == 0);
}

=head2 SetBorrowerAttributes 

  SetBorrowerAttributes($borrowernumber, [ { code => 'CODE', value => 'value', password => 'password' }, ... ] );

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
        if ($sth->err) {
            warn sprintf('Database returned the following error: %s', $sth->errstr);
            return; # bail immediately on errors
        }
    }
    return 1; # borower attributes successfully set
}

=head2 DeleteBorrowerAttribute

  DeleteBorrowerAttribute($borrowernumber, $attribute);

Delete a borrower attribute for the patron identified by C<$borrowernumber> and the attribute code of C<$attribute>

=cut
sub DeleteBorrowerAttribute {
    my ( $borrowernumber, $attribute ) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(qq{
        DELETE FROM borrower_attributes
            WHERE borrowernumber = ?
            AND code = ?
    } );
    $sth->execute( $borrowernumber, $attribute->{code} );
}

=head2 UpdateBorrowerAttribute

  UpdateBorrowerAttribute($borrowernumber, $attribute );

Update a borrower attribute C<$attribute> for the patron identified by C<$borrowernumber>,

=cut
sub UpdateBorrowerAttribute {
    my ( $borrowernumber, $attribute ) = @_;

    DeleteBorrowerAttribute $borrowernumber, $attribute;

    my $dbh = C4::Context->dbh;
    my $query = "INSERT INTO borrower_attributes SET attribute = ?, code = ?, borrowernumber = ?";
    my @params = ( $attribute->{attribute}, $attribute->{code}, $borrowernumber );
    if ( defined $attribute->{password} ) {
        $query .= ", password = ?";
        push @params, $attribute->{password};
    }
    my $sth = $dbh->prepare( $query );

    $sth->execute( @params );
}


=head2 extended_attributes_code_value_arrayref 

   my $patron_attributes = "homeroom:1150605,grade:01,extradata:foobar";
   my $aref = extended_attributes_code_value_arrayref($patron_attributes);

Takes a comma-delimited CSV-style string argument and returns the kind of data structure that SetBorrowerAttributes wants, 
namely a reference to array of hashrefs like:
 [ { code => 'CODE', value => 'value' }, { code => 'CODE2', value => 'othervalue' } ... ]

Caches Text::CSV parser object for efficiency.

=cut

sub extended_attributes_code_value_arrayref {
    my $string = shift or return;
    $csv or $csv = Text::CSV->new({binary => 1});  # binary needed for non-ASCII Unicode
    my $ok   = $csv->parse($string);  # parse field again to get subfields!
    my @list = $csv->fields();
    # TODO: error handling (check $ok)
    return [
        sort {&_sort_by_code($a,$b)}
        map { map { my @arr = split /:/, $_, 2; { code => $arr[0], value => $arr[1] } } $_ }
        @list
    ];
    # nested map because of split
}

=head2 extended_attributes_merge

  my $old_attributes = extended_attributes_code_value_arrayref("homeroom:224,grade:04,deanslist:2007,deanslist:2008,somedata:xxx");
  my $new_attributes = extended_attributes_code_value_arrayref("homeroom:115,grade:05,deanslist:2009,extradata:foobar");
  my $merged = extended_attributes_merge($patron_attributes, $new_attributes, 1);

  # assuming deanslist is a repeatable code, value same as:
  # $merged = extended_attributes_code_value_arrayref("homeroom:115,grade:05,deanslist:2007,deanslist:2008,deanslist:2009,extradata:foobar,somedata:xxx");

Takes three arguments.  The first two are references to array of hashrefs, each like:
 [ { code => 'CODE', value => 'value' }, { code => 'CODE2', value => 'othervalue' } ... ]

The third option specifies whether repeatable codes are clobbered or collected.  True for non-clobber.

Returns one reference to (merged) array of hashref.

Caches results of C4::Members::AttributeTypes::GetAttributeTypes_hashref(1) for efficiency.

=cut

sub extended_attributes_merge {
    my $old = shift or return;
    my $new = shift or return $old;
    my $keep = @_ ? shift : 0;
    $AttributeTypes or $AttributeTypes = C4::Members::AttributeTypes::GetAttributeTypes_hashref(1);
    my @merged = @$old;
    foreach my $att (@$new) {
        unless ($att->{code}) {
            warn "Cannot merge element: no 'code' defined";
            next;
        }
        unless ($AttributeTypes->{$att->{code}}) {
            warn "Cannot merge element: unrecognized code = '$att->{code}'";
            next;
        }
        unless ($AttributeTypes->{$att->{code}}->{repeatable} and $keep) {
            @merged = grep {$att->{code} ne $_->{code}} @merged;    # filter out any existing attributes of the same code
        }
        push @merged, $att;
    }
    return [( sort {&_sort_by_code($a,$b)} @merged )];
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
