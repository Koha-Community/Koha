package Koha::Schema::Result::Serial;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Serial

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

=head2 status

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 planneddate

  data_type: 'date'
  is_nullable: 1

=head2 notes

  data_type: 'text'
  is_nullable: 1

=head2 publisheddate

  data_type: 'date'
  is_nullable: 1

=head2 itemnumber

  data_type: 'text'
  is_nullable: 1

=head2 claimdate

  data_type: 'date'
  is_nullable: 1

=head2 routingnotes

  data_type: 'text'
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
  "status",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "planneddate",
  { data_type => "date", is_nullable => 1 },
  "notes",
  { data_type => "text", is_nullable => 1 },
  "publisheddate",
  { data_type => "date", is_nullable => 1 },
  "itemnumber",
  { data_type => "text", is_nullable => 1 },
  "claimdate",
  { data_type => "date", is_nullable => 1 },
  "routingnotes",
  { data_type => "text", is_nullable => 1 },
);
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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PqzibMlED9bg0uOONSBnmg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
