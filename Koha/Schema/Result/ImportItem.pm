package Koha::Schema::Result::ImportItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::ImportItem

=cut

__PACKAGE__->table("import_items");

=head1 ACCESSORS

=head2 import_items_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 import_record_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 itemnumber

  data_type: 'integer'
  is_nullable: 1

=head2 branchcode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 status

  data_type: 'enum'
  default_value: 'staged'
  extra: {list => ["error","staged","imported","reverted","ignored"]}
  is_nullable: 0

=head2 marcxml

  data_type: 'longtext'
  is_nullable: 0

=head2 import_error

  data_type: 'mediumtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "import_items_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "import_record_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "itemnumber",
  { data_type => "integer", is_nullable => 1 },
  "branchcode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "status",
  {
    data_type => "enum",
    default_value => "staged",
    extra => { list => ["error", "staged", "imported", "reverted", "ignored"] },
    is_nullable => 0,
  },
  "marcxml",
  { data_type => "longtext", is_nullable => 0 },
  "import_error",
  { data_type => "mediumtext", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("import_items_id");

=head1 RELATIONS

=head2 import_record

Type: belongs_to

Related object: L<Koha::Schema::Result::ImportRecord>

=cut

__PACKAGE__->belongs_to(
  "import_record",
  "Koha::Schema::Result::ImportRecord",
  { import_record_id => "import_record_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2PCGat+VP/DjjEe+G0gb3Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
