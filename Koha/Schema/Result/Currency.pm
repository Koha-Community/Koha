use utf8;
package Koha::Schema::Result::Currency;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Currency

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<currency>

=cut

__PACKAGE__->table("currency");

=head1 ACCESSORS

=head2 currency

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 symbol

  data_type: 'varchar'
  is_nullable: 1
  size: 5

=head2 isocode

  data_type: 'varchar'
  is_nullable: 1
  size: 5

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 rate

  data_type: 'float'
  is_nullable: 1
  size: [15,5]

=head2 active

  data_type: 'tinyint'
  is_nullable: 1

=head2 archived

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 p_sep_by_space

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "currency",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "symbol",
  { data_type => "varchar", is_nullable => 1, size => 5 },
  "isocode",
  { data_type => "varchar", is_nullable => 1, size => 5 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "rate",
  { data_type => "float", is_nullable => 1, size => [15, 5] },
  "active",
  { data_type => "tinyint", is_nullable => 1 },
  "archived",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "p_sep_by_space",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</currency>

=back

=cut

__PACKAGE__->set_primary_key("currency");

=head1 RELATIONS

=head2 aqbooksellers_invoiceprices

Type: has_many

Related object: L<Koha::Schema::Result::Aqbookseller>

=cut

__PACKAGE__->has_many(
  "aqbooksellers_invoiceprices",
  "Koha::Schema::Result::Aqbookseller",
  { "foreign.invoiceprice" => "self.currency" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 aqbooksellers_listprices

Type: has_many

Related object: L<Koha::Schema::Result::Aqbookseller>

=cut

__PACKAGE__->has_many(
  "aqbooksellers_listprices",
  "Koha::Schema::Result::Aqbookseller",
  { "foreign.listprice" => "self.currency" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 aqorders

Type: has_many

Related object: L<Koha::Schema::Result::Aqorder>

=cut

__PACKAGE__->has_many(
  "aqorders",
  "Koha::Schema::Result::Aqorder",
  { "foreign.currency" => "self.currency" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-01 14:23:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PnJEcCgrM1Edf99phWFdyQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
