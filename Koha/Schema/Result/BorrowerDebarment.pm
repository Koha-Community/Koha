use utf8;
package Koha::Schema::Result::BorrowerDebarment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BorrowerDebarment

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<borrower_debarments>

=cut

__PACKAGE__->table("borrower_debarments");

=head1 ACCESSORS

=head2 borrower_debarment_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique key for the restriction

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

foreign key for borrowers.borrowernumber for patron who is restricted

=head2 expiration

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

expiration date of the restriction

=head2 type

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 50

type of restriction, FK to restriction_types.code

=head2 comment

  data_type: 'mediumtext'
  is_nullable: 1

comments about the restriction

=head2 manager_id

  data_type: 'integer'
  is_nullable: 1

foreign key for borrowers.borrowernumber for the librarian managing the restriction

=head2 created

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

date the restriction was added

=head2 updated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date the restriction was updated

=cut

__PACKAGE__->add_columns(
  "borrower_debarment_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "expiration",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "type",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 50 },
  "comment",
  { data_type => "mediumtext", is_nullable => 1 },
  "manager_id",
  { data_type => "integer", is_nullable => 1 },
  "created",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "updated",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</borrower_debarment_id>

=back

=cut

__PACKAGE__->set_primary_key("borrower_debarment_id");

=head1 RELATIONS

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

=head2 type

Type: belongs_to

Related object: L<Koha::Schema::Result::RestrictionType>

=cut

__PACKAGE__->belongs_to(
  "type",
  "Koha::Schema::Result::RestrictionType",
  { code => "type" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-08-19 17:53:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kDCkA7XrjKXlrFG5lk8Lgg

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Patron::Restrictions';
}

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Patron::Restriction';
}

1;
