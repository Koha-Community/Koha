use utf8;
package Koha::Schema::Result::Review;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Review

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<reviews>

=cut

__PACKAGE__->table("reviews");

=head1 ACCESSORS

=head2 reviewid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier for this comment

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key from the borrowers table defining which patron left this comment

=head2 biblionumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key from the biblio table defining which bibliographic record this comment is for

=head2 review

  data_type: 'mediumtext'
  is_nullable: 1

the body of the comment

=head2 approved

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

whether this comment has been approved by a librarian (1 for yes, 0 for no)

=head2 datereviewed

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

the date the comment was left

=cut

__PACKAGE__->add_columns(
  "reviewid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "biblionumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "review",
  { data_type => "mediumtext", is_nullable => 1 },
  "approved",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "datereviewed",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</reviewid>

=back

=cut

__PACKAGE__->set_primary_key("reviewid");

=head1 RELATIONS

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1Am1qqe4ETom7ylth3Tvpg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
