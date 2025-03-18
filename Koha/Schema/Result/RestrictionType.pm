use utf8;
package Koha::Schema::Result::RestrictionType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::RestrictionType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<restriction_types>

=cut

__PACKAGE__->table("restriction_types");

=head1 ACCESSORS

=head2 code

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 display_text

  data_type: 'text'
  is_nullable: 0

=head2 is_system

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 is_default

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 lift_after_payment

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 fee_limit

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=cut

__PACKAGE__->add_columns(
  "code",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "display_text",
  { data_type => "text", is_nullable => 0 },
  "is_system",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "is_default",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "lift_after_payment",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "fee_limit",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
);

=head1 PRIMARY KEY

=over 4

=item * L</code>

=back

=cut

__PACKAGE__->set_primary_key("code");

=head1 RELATIONS

=head2 borrower_debarments

Type: has_many

Related object: L<Koha::Schema::Result::BorrowerDebarment>

=cut

__PACKAGE__->has_many(
  "borrower_debarments",
  "Koha::Schema::Result::BorrowerDebarment",
  { "foreign.type" => "self.code" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-10-11 14:33:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sYJS1OhmHvr8hUFwaGBdjQ

__PACKAGE__->add_columns(
    '+is_system'          => { is_boolean => 1 },
    '+is_default'         => { is_boolean => 1 },
    '+lift_after_payment' => { is_boolean => 1 },
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Patron::Restriction::Type';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Patron::Restriction::Types';
}

1;
