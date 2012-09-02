package Koha::Schema::Result::Aqcontract;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Aqcontract

=cut

__PACKAGE__->table("aqcontract");

=head1 ACCESSORS

=head2 contractnumber

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 contractstartdate

  data_type: 'date'
  is_nullable: 1

=head2 contractenddate

  data_type: 'date'
  is_nullable: 1

=head2 contractname

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 contractdescription

  data_type: 'mediumtext'
  is_nullable: 1

=head2 booksellerid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "contractnumber",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "contractstartdate",
  { data_type => "date", is_nullable => 1 },
  "contractenddate",
  { data_type => "date", is_nullable => 1 },
  "contractname",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "contractdescription",
  { data_type => "mediumtext", is_nullable => 1 },
  "booksellerid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("contractnumber");

=head1 RELATIONS

=head2 aqbaskets

Type: has_many

Related object: L<Koha::Schema::Result::Aqbasket>

=cut

__PACKAGE__->has_many(
  "aqbaskets",
  "Koha::Schema::Result::Aqbasket",
  { "foreign.contractnumber" => "self.contractnumber" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 booksellerid

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbookseller>

=cut

__PACKAGE__->belongs_to(
  "booksellerid",
  "Koha::Schema::Result::Aqbookseller",
  { id => "booksellerid" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ycOR9kVN0T7MmqtyS5ymww


# You can replace this text with custom content, and it will be preserved on regeneration
1;
