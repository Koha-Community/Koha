use utf8;
package Koha::Schema::Result::EdifactError;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::EdifactError

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<edifact_errors>

=cut

__PACKAGE__->table("edifact_errors");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 message_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 section

  data_type: 'mediumtext'
  is_nullable: 1

=head2 details

  data_type: 'mediumtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "message_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "section",
  { data_type => "mediumtext", is_nullable => 1 },
  "details",
  { data_type => "mediumtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 message

Type: belongs_to

Related object: L<Koha::Schema::Result::EdifactMessage>

=cut

__PACKAGE__->belongs_to(
  "message",
  "Koha::Schema::Result::EdifactMessage",
  { id => "message_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-02-21 15:22:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:e6TNAJbngU94ZrRDcp1OlQ

=head1 OBJECT HELPERS

=head2 koha_objects_class

Name of corresponding Koha::Objects class

=cut

sub koha_objects_class {
    'Koha::Edifact::File::Errors';
}

=head2 koha_object_class

Name of corresponding Koha::Object class

=cut

sub koha_object_class {
    'Koha::Edifact::File::Error';
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
