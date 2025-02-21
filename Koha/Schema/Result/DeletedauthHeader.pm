use utf8;
package Koha::Schema::Result::DeletedauthHeader;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::DeletedauthHeader

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<deletedauth_header>

=cut

__PACKAGE__->table("deletedauth_header");

=head1 ACCESSORS

=head2 authid

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 authtypecode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 datecreated

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 modification_time

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 heading

  data_type: 'longtext'
  is_nullable: 1

=head2 origincode

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 authtrees

  data_type: 'longtext'
  is_nullable: 1

=head2 linkid

  data_type: 'bigint'
  is_nullable: 1

=head2 marcxml

  data_type: 'longtext'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "authid",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "authtypecode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "datecreated",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "modification_time",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "heading",
  { data_type => "longtext", is_nullable => 1 },
  "origincode",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "authtrees",
  { data_type => "longtext", is_nullable => 1 },
  "linkid",
  { data_type => "bigint", is_nullable => 1 },
  "marcxml",
  { data_type => "longtext", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</authid>

=back

=cut

__PACKAGE__->set_primary_key("authid");


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-02-21 09:29:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XXLocKE3YUBM3xEPLuIN+g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
