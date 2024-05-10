use utf8;
package Koha::Schema::Result::PseudonymizedBorrowerAttribute;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PseudonymizedBorrowerAttribute

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<pseudonymized_borrower_attributes>

=cut

__PACKAGE__->table("pseudonymized_borrower_attributes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

Row id field

=head2 transaction_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 code

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 64

foreign key from the borrower_attribute_types table, defines which custom field this value was entered for

=head2 attribute

  data_type: 'varchar'
  is_nullable: 1
  size: 255

custom patron field value

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "transaction_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "code",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 64 },
  "attribute",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 code

Type: belongs_to

Related object: L<Koha::Schema::Result::BorrowerAttributeType>

=cut

__PACKAGE__->belongs_to(
  "code",
  "Koha::Schema::Result::BorrowerAttributeType",
  { code => "code" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 transaction

Type: belongs_to

Related object: L<Koha::Schema::Result::PseudonymizedTransaction>

=cut

__PACKAGE__->belongs_to(
  "transaction",
  "Koha::Schema::Result::PseudonymizedTransaction",
  { id => "transaction_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-05-10 14:00:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:09zbX6WErMxrZSBrc/nvdA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
