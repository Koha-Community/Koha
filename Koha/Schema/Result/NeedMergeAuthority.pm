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

=head2 authid_new

  data_type: 'bigint'
  is_nullable: 1

=head2 reportxml

  data_type: 'mediumtext'
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
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
  "authid_new",
  { data_type => "bigint", is_nullable => 1 },
  "reportxml",
  { data_type => "mediumtext", is_nullable => 1 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "done",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7LzwIYvExKvNgr8/HDZlsg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
