use utf8;
package Koha::Schema::Result::Serial;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Serial

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<serial>

=cut

__PACKAGE__->table("serial");

=head1 ACCESSORS

=head2 serialid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 biblionumber

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

=head2 subscriptionid

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

=head2 serialseq

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

=head2 serialseq_x

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 serialseq_y

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 serialseq_z

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 status

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 planneddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 notes

  data_type: 'mediumtext'
  is_nullable: 1

=head2 publisheddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 publisheddatetext

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 claimdate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 claims_count

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 routingnotes

  data_type: 'mediumtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "serialid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "biblionumber",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 100 },
  "subscriptionid",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 100 },
  "serialseq",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 100 },
  "serialseq_x",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "serialseq_y",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "serialseq_z",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "status",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "planneddate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "notes",
  { data_type => "mediumtext", is_nullable => 1 },
  "publisheddate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "publisheddatetext",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "claimdate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "claims_count",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "routingnotes",
  { data_type => "mediumtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</serialid>

=back

=cut

__PACKAGE__->set_primary_key("serialid");

=head1 RELATIONS

=head2 serialitems

Type: has_many

Related object: L<Koha::Schema::Result::Serialitem>

=cut

__PACKAGE__->has_many(
  "serialitems",
  "Koha::Schema::Result::Serialitem",
  { "foreign.serialid" => "self.serialid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sRygXoIOnqpdk0lqVMcBdA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
