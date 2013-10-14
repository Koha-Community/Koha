use utf8;
package Koha::Schema::Result::NeedMergeAuthority;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::NeedMergeAuthority

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<need_merge_authorities>

=cut

__PACKAGE__->table("need_merge_authorities");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 authid

  data_type: 'bigint'
  is_nullable: 0

=head2 done

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "authid",
  { data_type => "bigint", is_nullable => 0 },
  "done",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BL9ArSyPrmUG0QrrWgoPSw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
