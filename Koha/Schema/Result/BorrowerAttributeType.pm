use utf8;
package Koha::Schema::Result::BorrowerAttributeType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BorrowerAttributeType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<borrower_attribute_types>

=cut

__PACKAGE__->table("borrower_attribute_types");

=head1 ACCESSORS

=head2 code

  data_type: 'varchar'
  is_nullable: 0
  size: 64

unique key used to identify each custom field

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 255

description for each custom field

=head2 repeatable

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

defines whether one patron/borrower can have multiple values for this custom field  (1 for yes, 0 for no)

=head2 unique_id

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

defines if this value needs to be unique (1 for yes, 0 for no)

=head2 is_date

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

defines if this field is displayed as a date

=head2 opac_display

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

defines if this field is visible to patrons on their account in the OPAC (1 for yes, 0 for no)

=head2 opac_editable

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

defines if this field is editable by patrons on their account in the OPAC (1 for yes, 0 for no)

=head2 staff_searchable

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

defines if this field is searchable via the patron search in the staff interface (1 for yes, 0 for no)

=head2 searched_by_default

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

defines if this field is included in "Standard" patron searches in the staff interface (1 for yes, 0 for no)

=head2 authorised_value_category

  data_type: 'varchar'
  is_nullable: 1
  size: 32

foreign key from authorised_values that links this custom field to an authorized value category

=head2 display_checkout

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

defines if this field displays in checkout screens

=head2 category_code

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

defines a category for an attribute_type

=head2 class

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

defines a class for an attribute_type

=head2 keep_for_pseudonymization

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

defines if this field is copied to anonymized_borrower_attributes (1 for yes, 0 for no)

=head2 mandatory

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

defines if the attribute is mandatory or not in the staff interface

=head2 opac_mandatory

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

defines if the attribute is mandatory or not in the OPAC

=cut

__PACKAGE__->add_columns(
  "code",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "repeatable",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "unique_id",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "is_date",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "opac_display",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "opac_editable",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "staff_searchable",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "searched_by_default",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "authorised_value_category",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "display_checkout",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "category_code",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "class",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "keep_for_pseudonymization",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "mandatory",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "opac_mandatory",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</code>

=back

=cut

__PACKAGE__->set_primary_key("code");

=head1 RELATIONS

=head2 borrower_attribute_types_branches

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerAttributeTypesBranch>

=cut

__PACKAGE__->has_many(
  "borrower_attribute_types_branches",
  "Koha::Schema::Result::BorrowerAttributeTypesBranch",
  { "foreign.bat_code" => "self.code" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 borrower_attributes

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerAttribute>

=cut

__PACKAGE__->has_many(
  "borrower_attributes",
  "Koha::Schema::Result::BorrowerAttribute",
  { "foreign.code" => "self.code" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 category_code

Type: belongs_to

Related object: L<Koha::Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "category_code",
  "Koha::Schema::Result::Category",
  { categorycode => "category_code" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 pseudonymized_borrower_attributes

Type: has_many

Related object: L<Koha::Schema::Result::PseudonymizedBorrowerAttribute>

=cut

__PACKAGE__->has_many(
  "pseudonymized_borrower_attributes",
  "Koha::Schema::Result::PseudonymizedBorrowerAttribute",
  { "foreign.code" => "self.code" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-02-20 15:56:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Os1rn9zKu7/rVLVjZM3Mbg

__PACKAGE__->add_columns(
    '+display_checkout'          => { is_boolean => 1 },
    '+is_date'                   => { is_boolean => 1 },
    '+keep_for_pseudonymization' => { is_boolean => 1 },
    '+mandatory'                 => { is_boolean => 1 },
    '+opac_display'              => { is_boolean => 1 },
    '+opac_editable'             => { is_boolean => 1 },
    '+opac_mandatory'            => { is_boolean => 1 },
    '+repeatable'                => { is_boolean => 1 },
    '+searched_by_default'       => { is_boolean => 1 },
    '+staff_searchable'          => { is_boolean => 1 },
    '+unique_id'                 => { is_boolean => 1 },
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Patron::Attribute::Type';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Patron::Attribute::Types';
}

1;
