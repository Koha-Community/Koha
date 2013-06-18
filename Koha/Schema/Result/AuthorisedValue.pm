package Koha::Schema::Result::AuthorisedValue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::AuthorisedValue

=cut

__PACKAGE__->table("authorised_values");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 category

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 16

=head2 authorised_value

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 80

=head2 lib

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 lib_opac

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 imageurl

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "category",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 16 },
  "authorised_value",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "lib",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "lib_opac",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "imageurl",
  { data_type => "varchar", is_nullable => 1, size => 200 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 authorised_values_branches

Type: has_many

Related object: L<Koha::Schema::Result::AuthorisedValuesBranch>

=cut

__PACKAGE__->has_many(
  "authorised_values_branches",
  "Koha::Schema::Result::AuthorisedValuesBranch",
  { "foreign.av_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2013-06-18 13:13:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UQnP1vJKTnc7KwuTT20Orw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
