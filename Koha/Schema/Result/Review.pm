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

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 biblionumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 review

  data_type: 'mediumtext'
  is_nullable: 1

=head2 approved

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 datereviewed

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gEngecP849wzHprYW7H2tw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
