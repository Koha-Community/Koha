package C4::Members::AttributeTypes;

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
#use warnings; FIXME - Bug 2505
use C4::Context;

use vars qw($VERSION);

BEGIN {
    # set the version for version checking
    $VERSION = 3.07.00.049;
}

=head1 NAME

C4::Members::AttributeTypes - mananage extended patron attribute types

=head1 SYNOPSIS

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

=head1 FUNCTIONS

=head2 GetAttributeTypes

  my @attribute_types = C4::Members::AttributeTypes::GetAttributeTypes($all_fields);

Returns an array of hashrefs of each attribute type defined
in the database.  The array is sorted by code.  Each hashref contains
at least the following fields:

 - code
 - description

If $all_fields is true, then each hashref also contains the other fields from borrower_attribute_types.

=cut

sub GetAttributeTypes {
    my $all    = @_   ? shift : 0;
    my $no_branch_limit = @_ ? shift : 0;
    my $branch_limit = $no_branch_limit
        ? 0
        : C4::Context->userenv ? C4::Context->userenv->{"branch"} : 0;
    my $select = $all ? '*'   : 'DISTINCT(code), description, class';

    my $dbh = C4::Context->dbh;
    my $query = "SELECT $select FROM borrower_attribute_types";
    $query .= qq{
        LEFT JOIN borrower_attribute_types_branches ON bat_code = code
        WHERE b_branchcode = ? OR b_branchcode IS NULL
    } if $branch_limit;
    $query .= " ORDER BY code";
    my $sth    = $dbh->prepare($query);
    $sth->execute( $branch_limit ? $branch_limit : () );
    my $results = $sth->fetchall_arrayref({});
    $sth->finish;
    return @$results;
}

sub GetAttributeTypes_hashref {
    my %hash = map {$_->{code} => $_} GetAttributeTypes(@_);
    return \%hash;
}

=head2 AttributeTypeExists

  my $have_attr_xyz = C4::Members::AttributeTypes::AttributeTypeExists($code)

Returns true if we have attribute type C<$code>
in the database.

=cut

sub AttributeTypeExists {
    my ($code) = @_;
    my $dbh = C4::Context->dbh;
    my $exists = $dbh->selectrow_array("SELECT code FROM borrower_attribute_types WHERE code = ?", undef, $code);
    return $exists;
}

=head1 METHODS 

  my $attr_type = C4::Members::AttributeTypes->new($code, $description);

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
    $self->{'display_checkout'} = 0;
    $self->{'authorised_value_category'} = '';
    $self->{'category_code'} = '';
    $self->{'category_description'} = '';
    $self->{'class'} = '';

    bless $self, $class;
    return $self;
}

=head2 fetch

  my $attr_type = C4::Members::AttributeTypes->fetch($code);

Fetches an attribute type from the database.  If no
type with the given C<$code> exists, returns undef.

=cut

sub fetch {
    my $class = shift;
    my $code = shift;
    my $self = {};
    my $dbh = C4::Context->dbh();

    my $sth = $dbh->prepare_cached("
        SELECT borrower_attribute_types.*, categories.description AS category_description
        FROM borrower_attribute_types
        LEFT JOIN categories ON borrower_attribute_types.category_code=categories.categorycode
        WHERE code =?");
    $sth->execute($code);
    my $row = $sth->fetchrow_hashref;
    $sth->finish();
    return unless defined $row;

    $self->{'code'}                      = $row->{'code'};
    $self->{'description'}               = $row->{'description'};
    $self->{'repeatable'}                = $row->{'repeatable'};
    $self->{'unique_id'}                 = $row->{'unique_id'};
    $self->{'opac_display'}              = $row->{'opac_display'};
    $self->{'password_allowed'}          = $row->{'password_allowed'};
    $self->{'staff_searchable'}          = $row->{'staff_searchable'};
    $self->{'display_checkout'}          = $row->{'display_checkout'};
    $self->{'authorised_value_category'} = $row->{'authorised_value_category'};
    $self->{'category_code'}             = $row->{'category_code'};
    $self->{'category_description'}      = $row->{'category_description'};
    $self->{'class'}                     = $row->{'class'};

    $sth = $dbh->prepare("SELECT branchcode, branchname FROM borrower_attribute_types_branches, branches WHERE b_branchcode = branchcode AND bat_code = ?;");
    $sth->execute( $code );
    while ( my $data = $sth->fetchrow_hashref ) {
        push @{ $self->{branches} }, $data;
    }
    $sth->finish();

    bless $self, $class;
    return $self;
}

=head2 store

  $attr_type->store();

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
                                         authorised_value_category = ?,
                                         display_checkout = ?,
                                         category_code = ?,
                                         class = ?
                                     WHERE code = ?");
    } else {
        $sth = $dbh->prepare_cached("INSERT INTO borrower_attribute_types 
                                        (description, repeatable, unique_id, opac_display, password_allowed,
                                         staff_searchable, authorised_value_category, display_checkout, category_code, class, code)
                                        VALUES (?, ?, ?, ?, ?,
                                                ?, ?, ?, ?, ?, ?)");
    }
    $sth->bind_param(1, $self->{'description'});
    $sth->bind_param(2, $self->{'repeatable'});
    $sth->bind_param(3, $self->{'unique_id'});
    $sth->bind_param(4, $self->{'opac_display'});
    $sth->bind_param(5, $self->{'password_allowed'});
    $sth->bind_param(6, $self->{'staff_searchable'});
    $sth->bind_param(7, $self->{'authorised_value_category'});
    $sth->bind_param(8, $self->{'display_checkout'});
    $sth->bind_param(9, $self->{'category_code'} || undef);
    $sth->bind_param(10, $self->{'class'});
    $sth->bind_param(11, $self->{'code'});
    $sth->execute;

    if ( defined $$self{branches} ) {
        $sth = $dbh->prepare("DELETE FROM borrower_attribute_types_branches WHERE bat_code = ?");
        $sth->execute( $$self{code} );
        $sth = $dbh->prepare(
            "INSERT INTO borrower_attribute_types_branches
                        ( bat_code, b_branchcode )
                        VALUES ( ?, ? )"
        );
        for my $branchcode ( @{$$self{branches}} ) {
            next if not $branchcode;
            $sth->bind_param( 1, $$self{code} );
            $sth->bind_param( 2, $branchcode );
            $sth->execute;
        }
    }
    $sth->finish;
}

=head2 code

  my $code = $attr_type->code();
  $attr_type->code($code);

Accessor.  Note that the code is immutable once
a type is created or fetched from the database.

=cut

sub code {
    my $self = shift;
    return $self->{'code'};
}

=head2 description

  my $description = $attr_type->description();
  $attr_type->description($description);

Accessor.

=cut

sub description {
    my $self = shift;
    @_ ? $self->{'description'} = shift : $self->{'description'};
}

=head2 branches

my $branches = $attr_type->branches();
$attr_type->branches($branches);

Accessor.

=cut

sub branches {
    my $self = shift;
    @_ ? $self->{branches} = shift : $self->{branches};
}

=head2 repeatable

  my $repeatable = $attr_type->repeatable();
  $attr_type->repeatable($repeatable);

Accessor.  The C<$repeatable> argument
is interpreted as a Perl boolean.

=cut

sub repeatable {
    my $self = shift;
    @_ ? $self->{'repeatable'} = ((shift) ? 1 : 0) : $self->{'repeatable'};
}

=head2 unique_id

  my $unique_id = $attr_type->unique_id();
  $attr_type->unique_id($unique_id);

Accessor.  The C<$unique_id> argument
is interpreted as a Perl boolean.

=cut

sub unique_id {
    my $self = shift;
    @_ ? $self->{'unique_id'} = ((shift) ? 1 : 0) : $self->{'unique_id'};
}
=head2 opac_display

  my $opac_display = $attr_type->opac_display();
  $attr_type->opac_display($opac_display);

Accessor.  The C<$opac_display> argument
is interpreted as a Perl boolean.

=cut

sub opac_display {
    my $self = shift;
    @_ ? $self->{'opac_display'} = ((shift) ? 1 : 0) : $self->{'opac_display'};
}
=head2 password_allowed

  my $password_allowed = $attr_type->password_allowed();
  $attr_type->password_allowed($password_allowed);

Accessor.  The C<$password_allowed> argument
is interpreted as a Perl boolean.

=cut

sub password_allowed {
    my $self = shift;
    @_ ? $self->{'password_allowed'} = ((shift) ? 1 : 0) : $self->{'password_allowed'};
}
=head2 staff_searchable

  my $staff_searchable = $attr_type->staff_searchable();
  $attr_type->staff_searchable($staff_searchable);

Accessor.  The C<$staff_searchable> argument
is interpreted as a Perl boolean.

=cut

sub staff_searchable {
    my $self = shift;
    @_ ? $self->{'staff_searchable'} = ((shift) ? 1 : 0) : $self->{'staff_searchable'};
}

=head2 display_checkout

my $display_checkout = $attr_type->display_checkout();
$attr_type->display_checkout($display_checkout);

Accessor.  The C<$display_checkout> argument
is interpreted as a Perl boolean.

=cut

sub display_checkout {
    my $self = shift;
    @_ ? $self->{'display_checkout'} = ((shift) ? 1 : 0) : $self->{'display_checkout'};
}

=head2 authorised_value_category

  my $authorised_value_category = $attr_type->authorised_value_category();
  $attr_type->authorised_value_category($authorised_value_category);

Accessor.

=cut

sub authorised_value_category {
    my $self = shift;
    @_ ? $self->{'authorised_value_category'} = shift : $self->{'authorised_value_category'};
}

=head2 category_code

my $category_code = $attr_type->category_code();
$attr_type->category_code($category_code);

Accessor.

=cut

sub category_code {
    my $self = shift;
    @_ ? $self->{'category_code'} = shift : $self->{'category_code'};
}

=head2 category_description

my $category_description = $attr_type->category_description();
$attr_type->category_description($category_description);

Accessor.

=cut

sub category_description {
    my $self = shift;
    @_ ? $self->{'category_description'} = shift : $self->{'category_description'};
}

=head2 class

my $class = $attr_type->class();
$attr_type->class($class);

Accessor.

=cut

sub class {
    my $self = shift;
    @_ ? $self->{'class'} = shift : $self->{'class'};
}


=head2 delete

  $attr_type->delete();
  C4::Members::AttributeTypes->delete($code);

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
    $sth->finish;
}

=head2 num_patrons

  my $count = $attr_type->num_patrons();

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

  my @borrowernumbers = $attr_type->get_patrons($attribute);

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

Koha Development Team <http://koha-community.org/>

Galen Charlton <galen.charlton@liblime.com>

=cut

1;
