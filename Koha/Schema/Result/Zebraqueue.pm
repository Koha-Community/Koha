package Koha::Schema::Result::Zebraqueue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Zebraqueue

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
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WrwJr7Op+i6ck0EwiBADCA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
