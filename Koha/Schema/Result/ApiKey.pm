use utf8;
package Koha::Schema::Result::ApiKey;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ApiKey

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<api_keys>

=cut

__PACKAGE__->table("api_keys");

=head1 ACCESSORS

=head2 api_key_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 api_key

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 last_request_time

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 active

  data_type: 'integer'
  default_value: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "api_key_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "api_key",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "last_request_time",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "active",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</api_key_id>

=back

=cut

__PACKAGE__->set_primary_key("api_key_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<apk_bornumkey_idx>

=over 4

=item * L</borrowernumber>

=item * L</api_key>

=back

=cut

__PACKAGE__->add_unique_constraint("apk_bornumkey_idx", ["borrowernumber", "api_key"]);

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-07-31 11:03:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8nljlCCakQs1X0kTmW7PYw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
