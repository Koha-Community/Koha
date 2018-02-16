use utf8;
package Koha::Schema::Result::Club;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Club

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<clubs>

=cut

__PACKAGE__->table("clubs");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 club_template_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'mediumtext'
  is_nullable: 1

=head2 date_start

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 date_end

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

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

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "club_template_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "date_start",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "date_end",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
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
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 club_enrollments

Type: has_many

Related object: L<Koha::Schema::Result::ClubEnrollment>

=cut

__PACKAGE__->has_many(
  "club_enrollments",
  "Koha::Schema::Result::ClubEnrollment",
  { "foreign.club_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 club_fields

Type: has_many

Related object: L<Koha::Schema::Result::ClubField>

=cut

__PACKAGE__->has_many(
  "club_fields",
  "Koha::Schema::Result::ClubField",
  { "foreign.club_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 club_template

Type: belongs_to

Related object: L<Koha::Schema::Result::ClubTemplate>

=cut

__PACKAGE__->belongs_to(
  "club_template",
  "Koha::Schema::Result::ClubTemplate",
  { id => "club_template_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6EB6FURHN+brOhDoPZVeGQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
