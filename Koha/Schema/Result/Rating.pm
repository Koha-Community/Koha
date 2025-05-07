use utf8;
package Koha::Schema::Result::Rating;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Rating

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<ratings>

=cut

__PACKAGE__->table("ratings");

=head1 ACCESSORS

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

the borrowernumber of the patron who left this rating (borrowers.borrowernumber)

=head2 biblionumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

the biblio this rating is for (biblio.biblionumber)

=head2 rating_value

  data_type: 'tinyint'
  is_nullable: 0

the rating, from 1 to 5

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "biblionumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "rating_value",
  { data_type => "tinyint", is_nullable => 0 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</borrowernumber>

=item * L</biblionumber>

=back

=cut

__PACKAGE__->set_primary_key("borrowernumber", "biblionumber");

=head1 RELATIONS

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wUwI/h1WR8kVGMNCrv/tUQ

__PACKAGE__->add_columns(
    '+rating_value' => { is_boolean => 0 },
);

1;
