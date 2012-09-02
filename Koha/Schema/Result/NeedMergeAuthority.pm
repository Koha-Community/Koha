package Koha::Schema::Result::NeedMergeAuthority;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::NeedMergeAuthority

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
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8PCvOl9x3QoD3aqi9CCBwA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
