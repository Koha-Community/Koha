use utf8;
package Koha::Schema::Result::Aqbasket;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Aqbasket

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<aqbasket>

=cut

__PACKAGE__->table("aqbasket");

=head1 ACCESSORS

=head2 basketno

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key, Koha defined number

=head2 basketname

  data_type: 'varchar'
  is_nullable: 1
  size: 50

name given to the basket at creation

=head2 note

  data_type: 'longtext'
  is_nullable: 1

the internal note added at basket creation

=head2 booksellernote

  data_type: 'longtext'
  is_nullable: 1

the vendor note added at basket creation

=head2 contractnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

links this basket to the aqcontract table (aqcontract.contractnumber)

=head2 creationdate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

the date the basket was created

=head2 closedate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

the date the basket was closed

=head2 booksellerid

  data_type: 'integer'
  default_value: 1
  is_foreign_key: 1
  is_nullable: 0

the Koha assigned ID for the vendor (aqbooksellers.id)

=head2 authorisedby

  data_type: 'varchar'
  is_nullable: 1
  size: 10

the borrowernumber of the person who created the basket

=head2 booksellerinvoicenumber

  data_type: 'longtext'
  is_nullable: 1

appears to always be NULL

=head2 basketgroupid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

links this basket to its group (aqbasketgroups.id)

=head2 deliveryplace

  data_type: 'varchar'
  is_nullable: 1
  size: 10

basket delivery place

=head2 billingplace

  data_type: 'varchar'
  is_nullable: 1
  size: 10

basket billing place

=head2 branch

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

basket branch

=head2 is_standing

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

orders in this basket are standing

=head2 create_items

  data_type: 'enum'
  extra: {list => ["ordering","receiving","cataloguing"]}
  is_nullable: 1

when items should be created for orders in this basket

=cut

__PACKAGE__->add_columns(
  "basketno",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "basketname",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "note",
  { data_type => "longtext", is_nullable => 1 },
  "booksellernote",
  { data_type => "longtext", is_nullable => 1 },
  "contractnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "creationdate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "closedate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "booksellerid",
  {
    data_type      => "integer",
    default_value  => 1,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "authorisedby",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "booksellerinvoicenumber",
  { data_type => "longtext", is_nullable => 1 },
  "basketgroupid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "deliveryplace",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "billingplace",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "branch",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "is_standing",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "create_items",
  {
    data_type => "enum",
    extra => { list => ["ordering", "receiving", "cataloguing"] },
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</basketno>

=back

=cut

__PACKAGE__->set_primary_key("basketno");

=head1 RELATIONS

=head2 aqbasketusers

Type: has_many

Related object: L<Koha::Schema::Result::Aqbasketuser>

=cut

__PACKAGE__->has_many(
  "aqbasketusers",
  "Koha::Schema::Result::Aqbasketuser",
  { "foreign.basketno" => "self.basketno" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 aqorders

Type: has_many

Related object: L<Koha::Schema::Result::Aqorder>

=cut

__PACKAGE__->has_many(
  "aqorders",
  "Koha::Schema::Result::Aqorder",
  { "foreign.basketno" => "self.basketno" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 basketgroupid

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbasketgroup>

=cut

__PACKAGE__->belongs_to(
  "basketgroupid",
  "Koha::Schema::Result::Aqbasketgroup",
  { id => "basketgroupid" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "CASCADE",
  },
);

=head2 booksellerid

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbookseller>

=cut

__PACKAGE__->belongs_to(
  "booksellerid",
  "Koha::Schema::Result::Aqbookseller",
  { id => "booksellerid" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 branch

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branch",
  "Koha::Schema::Result::Branch",
  { branchcode => "branch" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 contractnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqcontract>

=cut

__PACKAGE__->belongs_to(
  "contractnumber",
  "Koha::Schema::Result::Aqcontract",
  { contractnumber => "contractnumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 edifact_messages

Type: has_many

Related object: L<Koha::Schema::Result::EdifactMessage>

=cut

__PACKAGE__->has_many(
  "edifact_messages",
  "Koha::Schema::Result::EdifactMessage",
  { "foreign.basketno" => "self.basketno" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 borrowernumbers

Type: many_to_many

Composing rels: L</aqbasketusers> -> borrowernumber

=cut

__PACKAGE__->many_to_many("borrowernumbers", "aqbasketusers", "borrowernumber");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6NoSiMu1GqEqT7F5wAVeig

__PACKAGE__->has_many(
  "additional_field_values",
  "Koha::Schema::Result::AdditionalFieldValue",
  sub {
    my ($args) = @_;

    return {
        "$args->{foreign_alias}.record_id" => { -ident => "$args->{self_alias}.basketno" },
        "$args->{foreign_alias}.record_table" => __PACKAGE__->table,
    };
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->belongs_to(
  "basket_group",
  "Koha::Schema::Result::Aqbasketgroup",
  { 'foreign.id' => "self.basketgroupid" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "CASCADE",
  },
);

__PACKAGE__->has_many(
  "orders",
  "Koha::Schema::Result::Aqorder",
  { "foreign.basketno" => "self.basketno" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->belongs_to(
  "vendor",
  "Koha::Schema::Result::Aqbookseller",
  { id => "booksellerid" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Acquisition::Basket';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Acquisition::Baskets';
}

__PACKAGE__->add_columns(
    '+is_standing' => { is_boolean => 1 }
);

1;
