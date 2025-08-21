use utf8;
package Koha::Schema::Result::PseudonymizedMetadataValue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PseudonymizedMetadataValue

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<pseudonymized_metadata_values>

=cut

__PACKAGE__->table("pseudonymized_metadata_values");

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

=head2 tablename

  data_type: 'varchar'
  is_nullable: 0
  size: 64

Name of the related table

=head2 key

  data_type: 'varchar'
  is_nullable: 0
  size: 64

key for the metadata

=head2 value

  data_type: 'varchar'
  is_nullable: 1
  size: 255

value for the metadata

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "transaction_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "tablename",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "key",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "value",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-08-20 19:38:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:76qV+mwWcMMxWH6q59ba9g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
