use utf8;
package Koha::Schema::Result::ClubTemplate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ClubTemplate

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<club_templates>

=cut

__PACKAGE__->table("club_templates");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'mediumtext'
  is_nullable: 1

=head2 is_enrollable_from_opac

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 is_email_required

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

=head2 date_created

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 date_updated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 is_deletable

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "is_enrollable_from_opac",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "is_email_required",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "date_created",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "date_updated",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "is_deletable",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 club_template_enrollment_fields

Type: has_many

Related object: L<Koha::Schema::Result::ClubTemplateEnrollmentField>

=cut

__PACKAGE__->has_many(
  "club_template_enrollment_fields",
  "Koha::Schema::Result::ClubTemplateEnrollmentField",
  { "foreign.club_template_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 club_template_fields

Type: has_many

Related object: L<Koha::Schema::Result::ClubTemplateField>

=cut

__PACKAGE__->has_many(
  "club_template_fields",
  "Koha::Schema::Result::ClubTemplateField",
  { "foreign.club_template_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 clubs

Type: has_many

Related object: L<Koha::Schema::Result::Club>

=cut

__PACKAGE__->has_many(
  "clubs",
  "Koha::Schema::Result::Club",
  { "foreign.club_template_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1UuejI9kkTb9eeNKvSLAQQ

1;
