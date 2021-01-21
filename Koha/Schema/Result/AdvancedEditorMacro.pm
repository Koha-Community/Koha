use utf8;
package Koha::Schema::Result::AdvancedEditorMacro;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AdvancedEditorMacro

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<advanced_editor_macros>

=cut

__PACKAGE__->table("advanced_editor_macros");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

Unique ID of the macro

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 80

Name of the macro

=head2 macro

  data_type: 'longtext'
  is_nullable: 1

The macro code itself

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

ID of the borrower who created this macro

=head2 shared

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

Bit to define if shared or private macro

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "macro",
  { data_type => "longtext", is_nullable => 1 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "shared",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:abYuKrQLDx8KB3ZdEGBlqA

__PACKAGE__->add_columns(
            '+shared' => { is_boolean => 1 },
        );

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
