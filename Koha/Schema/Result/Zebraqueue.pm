use utf8;
package Koha::Schema::Result::Zebraqueue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Zebraqueue

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<zebraqueue>

=cut

__PACKAGE__->table("zebraqueue");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 biblio_auth_number

  data_type: 'bigint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 operation

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 20

=head2 server

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 20

=head2 done

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 time

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "biblio_auth_number",
  {
    data_type => "bigint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "operation",
  { data_type => "char", default_value => "", is_nullable => 0, size => 20 },
  "server",
  { data_type => "char", default_value => "", is_nullable => 0, size => 20 },
  "done",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "time",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vU9ROiVUwXc7jhKt728dRg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
