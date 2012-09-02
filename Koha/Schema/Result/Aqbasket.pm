package Koha::Schema::Result::Aqbasket;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Aqbasket

=cut

__PACKAGE__->table("aqbasket");

=head1 ACCESSORS

=head2 basketno

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 basketname

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 note

  data_type: 'mediumtext'
  is_nullable: 1

=head2 booksellernote

  data_type: 'mediumtext'
  is_nullable: 1

=head2 contractnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 creationdate

  data_type: 'date'
  is_nullable: 1

=head2 closedate

  data_type: 'date'
  is_nullable: 1

=head2 booksellerid

  data_type: 'integer'
  default_value: 1
  is_foreign_key: 1
  is_nullable: 0

=head2 authorisedby

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 booksellerinvoicenumber

  data_type: 'mediumtext'
  is_nullable: 1

=head2 basketgroupid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "basketno",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "basketname",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "note",
  { data_type => "mediumtext", is_nullable => 1 },
  "booksellernote",
  { data_type => "mediumtext", is_nullable => 1 },
  "contractnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "creationdate",
  { data_type => "date", is_nullable => 1 },
  "closedate",
  { data_type => "date", is_nullable => 1 },
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
  { data_type => "mediumtext", is_nullable => 1 },
  "basketgroupid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("basketno");

=head1 RELATIONS

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

=head2 contractnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqcontract>

=cut

__PACKAGE__->belongs_to(
  "contractnumber",
  "Koha::Schema::Result::Aqcontract",
  { contractnumber => "contractnumber" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 basketgroupid

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbasketgroup>

=cut

__PACKAGE__->belongs_to(
  "basketgroupid",
  "Koha::Schema::Result::Aqbasketgroup",
  { id => "basketgroupid" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eRG3p93qKZhp3rNPwG60Ig


# You can replace this text with custom content, and it will be preserved on regeneration
1;
