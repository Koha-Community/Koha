package Koha::Schema::Result::Currency;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Currency

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

=head2 timestamp

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0

=head2 rate

  data_type: 'float'
  is_nullable: 1
  size: [15,5]

=head2 active

  data_type: 'tinyint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "currency",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "symbol",
  { data_type => "varchar", is_nullable => 1, size => 5 },
  "timestamp",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "rate",
  { data_type => "float", is_nullable => 1, size => [15, 5] },
  "active",
  { data_type => "tinyint", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("currency");

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6SWDTY33KjtpW71Elgs69g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
