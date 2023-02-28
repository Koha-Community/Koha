use utf8;
package Koha::Schema::Result::AdditionalContent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AdditionalContent

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<additional_contents>

=cut

__PACKAGE__->table("additional_contents");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

unique identifier for the additional content category

=head2 category

  data_type: 'varchar'
  is_nullable: 0
  size: 20

category for the additional content

=head2 code

  data_type: 'varchar'
  is_nullable: 0
  size: 100

code to group content per lang

=head2 location

  data_type: 'varchar'
  is_nullable: 0
  size: 255

location of the additional content

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

branch code users to create branch specific additional content, NULL is every branch.

=head2 published_on

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

publication date

=head2 updated_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

last modification

=head2 expirationdate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date the additional content is set to expire or no longer be visible

=head2 number

  data_type: 'integer'
  is_nullable: 1

the order in which this additional content appears in that specific location

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

The user who created the additional content

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "category",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "code",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "location",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "published_on",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "updated_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "expirationdate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "number",
  { data_type => "integer", is_nullable => 1 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<additional_contents_uniq>

=over 4

=item * L</category>

=item * L</code>

=item * L</branchcode>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "additional_contents_uniq",
  ["category", "code", "branchcode"],
);

=head1 RELATIONS

=head2 additional_contents_localizations

Type: has_many

Related object: L<Koha::Schema::Result::AdditionalContentsLocalization>

=cut

__PACKAGE__->has_many(
  "additional_contents_localizations",
  "Koha::Schema::Result::AdditionalContentsLocalization",
  { "foreign.additional_content_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-03-03 07:19:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0w/fOUAy+4V4aVls/i7Wig


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
