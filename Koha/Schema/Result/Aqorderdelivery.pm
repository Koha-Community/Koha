package Koha::Schema::Result::Aqorderdelivery;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Aqorderdelivery

=cut

__PACKAGE__->table("aqorderdelivery");

=head1 ACCESSORS

=head2 ordernumber

  data_type: 'date'
  is_nullable: 1

=head2 deliverynumber

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 deliverydate

  data_type: 'varchar'
  is_nullable: 1
  size: 18

=head2 qtydelivered

  data_type: 'smallint'
  is_nullable: 1

=head2 deliverycomments

  data_type: 'mediumtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "ordernumber",
  { data_type => "date", is_nullable => 1 },
  "deliverynumber",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "deliverydate",
  { data_type => "varchar", is_nullable => 1, size => 18 },
  "qtydelivered",
  { data_type => "smallint", is_nullable => 1 },
  "deliverycomments",
  { data_type => "mediumtext", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LOGL7qHtUGwgWbKJ1HguXA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
