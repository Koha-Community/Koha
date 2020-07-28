use utf8;
package Koha::Schema::Result::LibrarySmtpServer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::LibrarySmtpServer

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<library_smtp_servers>

=cut

__PACKAGE__->table("library_smtp_servers");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 library_id

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 smtp_server_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "library_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "smtp_server_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<library_id_idx>

=over 4

=item * L</library_id>

=back

=cut

__PACKAGE__->add_unique_constraint("library_id_idx", ["library_id"]);

=head1 RELATIONS

=head2 library

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "library",
  "Koha::Schema::Result::Branch",
  { branchcode => "library_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 smtp_server

Type: belongs_to

Related object: L<Koha::Schema::Result::SmtpServer>

=cut

__PACKAGE__->belongs_to(
  "smtp_server",
  "Koha::Schema::Result::SmtpServer",
  { id => "smtp_server_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-08-24 13:41:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qKAQAs3VFcitIGDGra/zuw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
