use utf8;
package Koha::Schema::Result::AdditionalContentsLocalization;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AdditionalContentsLocalization

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<additional_contents_localizations>

=cut

__PACKAGE__->table("additional_contents_localizations");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

unique identifier for the additional content

=head2 additional_content_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

link to the additional content

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 250

title of the additional content

=head2 content

  data_type: 'mediumtext'
  is_nullable: 0

the body of your additional content

=head2 lang

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 50

lang

=head2 updated_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

last modification

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "additional_content_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "title",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 250 },
  "content",
  { data_type => "mediumtext", is_nullable => 0 },
  "lang",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "updated_on",
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

=head1 UNIQUE CONSTRAINTS

=head2 C<additional_contents_localizations_uniq>

=over 4

=item * L</additional_content_id>

=item * L</lang>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "additional_contents_localizations_uniq",
  ["additional_content_id", "lang"],
);

=head1 RELATIONS

=head2 additional_content

Type: belongs_to

Related object: L<Koha::Schema::Result::AdditionalContent>

=cut

__PACKAGE__->belongs_to(
  "additional_content",
  "Koha::Schema::Result::AdditionalContent",
  { id => "additional_content_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-03-08 09:59:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7N/mHMqyPJJsYaA8V968wQ

=head2 koha_object_class

  Koha Object class

=cut

sub koha_object_class {
    'Koha::AdditionalContentsLocalization';
}

=head2 koha_objects_class

  Koha Objects class

=cut

sub koha_objects_class {
    'Koha::AdditionalContentsLocalizations';
}

1;
