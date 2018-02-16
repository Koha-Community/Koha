use utf8;
package Koha::Schema::Result::ClubField;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ClubField

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<club_fields>

=cut

__PACKAGE__->table("club_fields");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 club_template_field_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 club_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 value

  data_type: 'mediumtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "club_template_field_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "club_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "value",
  { data_type => "mediumtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 club

Type: belongs_to

Related object: L<Koha::Schema::Result::Club>

=cut

__PACKAGE__->belongs_to(
  "club",
  "Koha::Schema::Result::Club",
  { id => "club_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 club_template_field

Type: belongs_to

Related object: L<Koha::Schema::Result::ClubTemplateField>

=cut

__PACKAGE__->belongs_to(
  "club_template_field",
  "Koha::Schema::Result::ClubTemplateField",
  { id => "club_template_field_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2ySSLrl8GXRXJ38AWg6kng


# You can replace this text with custom content, and it will be preserved on regeneration
1;
