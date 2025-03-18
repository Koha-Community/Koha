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

unique id

=head2 authid

  data_type: 'bigint'
  is_nullable: 0

reference to original authority record

=head2 authid_new

  data_type: 'bigint'
  is_nullable: 1

reference to optional new authority record

=head2 reportxml

  data_type: 'mediumtext'
  is_nullable: 1

xml showing original reporting tag

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

date and time last modified

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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZGE483WQMHZLpdgAAPHMKg

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Authority::MergeRequest';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Authority::MergeRequests';
}

1;
