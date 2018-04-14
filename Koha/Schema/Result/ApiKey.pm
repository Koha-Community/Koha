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

=head2 client_id

  data_type: 'varchar'
  is_nullable: 0
  size: 191

=head2 secret

  data_type: 'varchar'
  is_nullable: 0
  size: 191

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 patron_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 active

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "client_id",
  { data_type => "varchar", is_nullable => 0, size => 191 },
  "secret",
  { data_type => "varchar", is_nullable => 0, size => 191 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "patron_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "active",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</client_id>

=back

=cut

__PACKAGE__->set_primary_key("client_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<secret>

=over 4

=item * L</secret>

=back

=cut

__PACKAGE__->add_unique_constraint("secret", ["secret"]);

=head1 RELATIONS

=head2 patron

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "patron",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "patron_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-04-14 14:48:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qnu4QSACpOSQaZgd52ozmw

__PACKAGE__->add_columns(
    '+active' => { is_boolean => 1 }
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
