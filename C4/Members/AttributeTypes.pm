package C4::Members::AttributeTypes;

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

use vars qw($VERSION);

BEGIN {
    # set the version for version checking
    $VERSION = 3.00;
}

=head1 NAME

C4::Members::AttributeTypes - mananage extended patron attribute types

=head1 SYNOPSIS

=over 4

my @attribute_types = C4::Members::AttributeTypes::GetAttributeTypes();

my $attr_type = C4::Members::AttributeTypes->new($code, $description);
$attr_type->code($code);
$attr_type->description($description);
$attr_type->repeatable($repeatable);
$attr_type->unique_id($unique_id);
$attr_type->opac_display($opac_display);
$attr_type->password_allowed($password_allowed);
$attr_type->staff_searchable($staff_searchable);
$attr_type->authorised_value_category($authorised_value_category);
$attr_type->store();
$attr_type->delete();

my $attr_type = C4::Members::AttributeTypes->fetch($code);
$attr_type = C4::Members::AttributeTypes->delete($code);

=back

=head1 FUNCTIONS

=head2 GetAttributeTypes

=over 4

my @attribute_types = C4::Members::AttributeTypes::GetAttributeTypes($all_fields);

=back

Returns an array of hashrefs of each attribute type defined
in the database.  The array is sorted by code.  Each hashref contains
at least the following fields:

code
description

If $all_fields is true, then each hashref also contains the other fields from borrower_attribute_types.

=cut

sub GetAttributeTypes {
    my $all = @_ ? shift : 0;
    my $select = $all ? '*' : 'code, description';
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT $select FROM borrower_attribute_types ORDER by code");
    $sth->execute();
    my $results = $sth->fetchall_arrayref({});
    return @$results;
}

sub GetAttributeTypes_hashref {
    my %hash = map {$_->{code} => $_} GetAttributeTypes(@_);
    return \%hash;
}

=head1 METHODS 

=over 4

my $attr_type = C4::Members::AttributeTypes->new($code, $description);

=back

Create a new attribute type.

=cut 

sub new {
    my $class = shift;
    my $self = {};

    $self->{'code'} = shift;
    $self->{'description'} = shift;
    $self->{'repeatable'} = 0;
    $self->{'unique_id'} = 0;
    $self->{'opac_display'} = 0;
    $self->{'password_allowed'} = 0;
    $self->{'staff_searchable'} = 0;
    $self->{'authorised_value_category'} = '';

    bless $self, $class;
    return $self;
}

=head2 fetch

=over 4

my $attr_type = C4::Members::AttributeTypes->fetch($code);

=back

Fetches an attribute type from the database.  If no
type with the given C<$code> exists, returns undef.

=cut

sub fetch {
    my $class = shift;
    my $code = shift;
    my $self = {};
    my $dbh = C4::Context->dbh();

    my $sth = $dbh->prepare_cached("SELECT * FROM borrower_attribute_types WHERE code = ?");
    $sth->execute($code);
    my $row = $sth->fetchrow_hashref;
    $sth->finish();
    return undef unless defined $row;    

    $self->{'code'}                      = $row->{'code'};
    $self->{'description'}               = $row->{'description'};
    $self->{'repeatable'}                = $row->{'repeatable'};
    $self->{'unique_id'}                 = $row->{'unique_id'};
    $self->{'opac_display'}              = $row->{'opac_display'};
    $self->{'password_allowed'}          = $row->{'password_allowed'};
    $self->{'staff_searchable'}          = $row->{'staff_searchable'};
    $self->{'authorised_value_category'} = $row->{'authorised_value_category'};

    bless $self, $class;
    return $self;
}

=head2 store

=over 4

$attr_type->store();

=back

Stores attribute type in the database.  If the type
previously retrieved from the database via the fetch()
method, the DB representation of the type is replaced.

=cut

sub store {
    my $self = shift;

    my $dbh = C4::Context->dbh;
    my $sth;
    my $existing = __PACKAGE__->fetch($self->{'code'});
    if (defined $existing) {
        $sth = $dbh->prepare_cached("UPDATE borrower_attribute_types
                                     SET description = ?,
                                         repeatable = ?,
                                         unique_id = ?,
                                         opac_display = ?,
                                         password_allowed = ?,
                                         staff_searchable = ?,
                                         authorised_value_category = ?
                                     WHERE code = ?");
    } else {
        $sth = $dbh->prepare_cached("INSERT INTO borrower_attribute_types 
                                        (description, repeatable, unique_id, opac_display, password_allowed,
                                         staff_searchable, authorised_value_category, code)
                                        VALUES (?, ?, ?, ?, ?,
                                                ?, ?, ?)");
    }
    $sth->bind_param(1, $self->{'description'});
    $sth->bind_param(2, $self->{'repeatable'});
    $sth->bind_param(3, $self->{'unique_id'});
    $sth->bind_param(4, $self->{'opac_display'});
    $sth->bind_param(5, $self->{'password_allowed'});
    $sth->bind_param(6, $self->{'staff_searchable'});
    $sth->bind_param(7, $self->{'authorised_value_category'});
    $sth->bind_param(8, $self->{'code'});
    $sth->execute;

}

=head2 code

=over 4

my $code = $attr_type->code();
$attr_type->code($code);

=back

Accessor.  Note that the code is immutable once
a type is created or fetched from the database.

=cut

sub code {
    my $self = shift;
    return $self->{'code'};
}

=head2 description

=over 4

my $description = $attr_type->description();
$attr_type->description($description);

=back

Accessor.

=cut

sub description {
    my $self = shift;
    @_ ? $self->{'description'} = shift : $self->{'description'};
}

=head2 repeatable

=over 4

my $repeatable = $attr_type->repeatable();
$attr_type->repeatable($repeatable);

=back

Accessor.  The C<$repeatable> argument
is interpreted as a Perl boolean.

=cut

sub repeatable {
    my $self = shift;
    @_ ? $self->{'repeatable'} = ((shift) ? 1 : 0) : $self->{'repeatable'};
}

=head2 unique_id

=over 4

my $unique_id = $attr_type->unique_id();
$attr_type->unique_id($unique_id);

=back

Accessor.  The C<$unique_id> argument
is interpreted as a Perl boolean.

=cut

sub unique_id {
    my $self = shift;
    @_ ? $self->{'unique_id'} = ((shift) ? 1 : 0) : $self->{'unique_id'};
}
=head2 opac_display

=over 4

my $opac_display = $attr_type->opac_display();
$attr_type->opac_display($opac_display);

=back

Accessor.  The C<$opac_display> argument
is interpreted as a Perl boolean.

=cut

sub opac_display {
    my $self = shift;
    @_ ? $self->{'opac_display'} = ((shift) ? 1 : 0) : $self->{'opac_display'};
}
=head2 password_allowed

=over 4

my $password_allowed = $attr_type->password_allowed();
$attr_type->password_allowed($password_allowed);

=back

Accessor.  The C<$password_allowed> argument
is interpreted as a Perl boolean.

=cut

sub password_allowed {
    my $self = shift;
    @_ ? $self->{'password_allowed'} = ((shift) ? 1 : 0) : $self->{'password_allowed'};
}
=head2 staff_searchable

=over 4

my $staff_searchable = $attr_type->staff_searchable();
$attr_type->staff_searchable($staff_searchable);

=back

Accessor.  The C<$staff_searchable> argument
is interpreted as a Perl boolean.

=cut

sub staff_searchable {
    my $self = shift;
    @_ ? $self->{'staff_searchable'} = ((shift) ? 1 : 0) : $self->{'staff_searchable'};
}

=head2 authorised_value_category

=over 4

my $authorised_value_category = $attr_type->authorised_value_category();
$attr_type->authorised_value_category($authorised_value_category);

=back

Accessor.

=cut

sub authorised_value_category {
    my $self = shift;
    @_ ? $self->{'authorised_value_category'} = shift : $self->{'authorised_value_category'};
}

=head2 delete

=over 4

$attr_type->delete();
C4::Members::AttributeTypes->delete($code);

=back

Delete an attribute type from the database.  The attribute
type may be specified either by an object or by a code.

=cut

sub delete {
    my $arg = shift;
    my $code;
    if (ref($arg) eq __PACKAGE__) {
        $code = $arg->{'code'};
    } else {
        $code = shift;
    }

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("DELETE FROM borrower_attribute_types WHERE code = ?");
    $sth->execute($code);
}

=head2 num_patrons

=over 4

my $count = $attr_type->num_patrons();

=back

Returns the number of patron records that use
this attribute type.

=cut

sub num_patrons {
    my $self = shift;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("SELECT COUNT(DISTINCT borrowernumber)
                                    FROM borrower_attributes
                                    WHERE code = ?");
    $sth->execute($self->{code});
    my ($count) = $sth->fetchrow_array;
    $sth->finish;
    return $count;
}

=head2 get_patrons

=over 4

my @borrowernumbers = $attr_type->get_patrons($attribute);

=back

Returns the borrowernumber of the patron records that
have an attribute with the specifie value.

=cut

sub get_patrons {
    my $self = shift;
    my $value = shift;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("SELECT DISTINCT borrowernumber
                                    FROM borrower_attributes
                                    WHERE code = ?
                                    AND   attribute = ?");
    $sth->execute($self->{code}, $value);
    my @results;
    while (my ($borrowernumber) = $sth->fetchrow_array) {
        push @results, $borrowernumber;
    } 
    return @results;
}

=head1 AUTHOR

Koha Development Team <info@koha.org>

Galen Charlton <galen.charlton@liblime.com>

=cut

1;
