use utf8;
package Koha::Schema::Result::Discharge;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Discharge

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<discharges>

=cut

__PACKAGE__->table("discharges");

=head1 ACCESSORS

=head2 borrower

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 needed

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 validated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "borrower",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "needed",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "validated",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 RELATIONS

=head2 borrower

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrower",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrower" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-01-08 18:15:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uq7Zb0SNf2mD3cpC4oub9A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
