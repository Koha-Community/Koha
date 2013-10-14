use utf8;
package Koha::Schema::Result::ImportAuth;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ImportAuth

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<import_auths>

=cut

__PACKAGE__->table("import_auths");

=head1 ACCESSORS

=head2 import_record_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 matched_authid

  data_type: 'integer'
  is_nullable: 1

=head2 control_number

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 authorized_heading

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 original_source

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=cut

__PACKAGE__->add_columns(
  "import_record_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "matched_authid",
  { data_type => "integer", is_nullable => 1 },
  "control_number",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "authorized_heading",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "original_source",
  { data_type => "varchar", is_nullable => 1, size => 25 },
);

=head1 RELATIONS

=head2 import_record

Type: belongs_to

Related object: L<Koha::Schema::Result::ImportRecord>

=cut

__PACKAGE__->belongs_to(
  "import_record",
  "Koha::Schema::Result::ImportRecord",
  { import_record_id => "import_record_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bm1ctlmYDh4qWUU95SLqBw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
