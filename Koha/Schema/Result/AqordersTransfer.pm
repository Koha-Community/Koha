use utf8;
package Koha::Schema::Result::AqordersTransfer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AqordersTransfer

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<aqorders_transfers>

=cut

__PACKAGE__->table("aqorders_transfers");

=head1 ACCESSORS

=head2 ordernumber_from

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 ordernumber_to

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "ordernumber_from",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "ordernumber_to",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<ordernumber_from>

=over 4

=item * L</ordernumber_from>

=back

=cut

__PACKAGE__->add_unique_constraint("ordernumber_from", ["ordernumber_from"]);

=head2 C<ordernumber_to>

=over 4

=item * L</ordernumber_to>

=back

=cut

__PACKAGE__->add_unique_constraint("ordernumber_to", ["ordernumber_to"]);

=head1 RELATIONS

=head2 ordernumber_from

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqorder>

=cut

__PACKAGE__->belongs_to(
  "ordernumber_from",
  "Koha::Schema::Result::Aqorder",
  { ordernumber => "ordernumber_from" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 ordernumber_to

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqorder>

=cut

__PACKAGE__->belongs_to(
  "ordernumber_to",
  "Koha::Schema::Result::Aqorder",
  { ordernumber => "ordernumber_to" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-07-11 09:26:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Z6+vESlzZKjZloNvrEHpxA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
