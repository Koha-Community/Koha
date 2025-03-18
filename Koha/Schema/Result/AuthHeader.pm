use utf8;
package Koha::Schema::Result::AuthHeader;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AuthHeader

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<auth_header>

=cut

__PACKAGE__->table("auth_header");

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

=head1 RELATIONS

=head2 import_oai_authorities

Type: has_many

Related object: L<Koha::Schema::Result::ImportOaiAuthority>

=cut

__PACKAGE__->has_many(
  "import_oai_authorities",
  "Koha::Schema::Result::ImportOaiAuthority",
  { "foreign.authid" => "self.authid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-02-21 09:20:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JkZ9DrxanaiZVU6d8pzpSA

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Authority';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Authorities';
}

1;
