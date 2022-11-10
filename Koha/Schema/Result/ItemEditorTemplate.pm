use utf8;
package Koha::Schema::Result::ItemEditorTemplate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ItemEditorTemplate

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<item_editor_templates>

=cut

__PACKAGE__->table("item_editor_templates");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

id for the template

=head2 patron_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

creator of this template

=head2 name

  data_type: 'mediumtext'
  is_nullable: 0

template name

=head2 is_shared

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

controls if template is shared

=head2 contents

  data_type: 'longtext'
  is_nullable: 0

json encoded template data

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "patron_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "name",
  { data_type => "mediumtext", is_nullable => 0 },
  "is_shared",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "contents",
  { data_type => "longtext", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 patron

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "patron",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "patron_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-11-10 17:43:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9W+tUIeeQnoitoQZ6d0wQg

__PACKAGE__->add_columns(
    '+is_shared' => { is_boolean => 1 },
);

=head2 koha_object_class

  Koha Object class

=cut

sub koha_object_class {
    'Koha::Item::Template';
}

=head2 koha_objects_class

  Koha Objects class

=cut

sub koha_objects_class {
    'Koha::Item::Templates';
}

1;
