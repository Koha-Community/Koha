use utf8;
package Koha::Schema::Result::ClubEnrollmentField;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ClubEnrollmentField

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<club_enrollment_fields>

=cut

__PACKAGE__->table("club_enrollment_fields");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 club_enrollment_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 club_template_enrollment_field_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 value

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "club_enrollment_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "club_template_enrollment_field_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "value",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 club_enrollment

Type: belongs_to

Related object: L<Koha::Schema::Result::ClubEnrollment>

=cut

__PACKAGE__->belongs_to(
  "club_enrollment",
  "Koha::Schema::Result::ClubEnrollment",
  { id => "club_enrollment_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 club_template_enrollment_field

Type: belongs_to

Related object: L<Koha::Schema::Result::ClubTemplateEnrollmentField>

=cut

__PACKAGE__->belongs_to(
  "club_template_enrollment_field",
  "Koha::Schema::Result::ClubTemplateEnrollmentField",
  { id => "club_template_enrollment_field_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2015-01-12 09:56:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2ANAs3mh3i/kd3Qxrcd5IA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
