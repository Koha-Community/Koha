use utf8;
package Koha::Schema::Result::Suggestion;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Suggestion

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<suggestions>

=cut

__PACKAGE__->table("suggestions");

=head1 ACCESSORS

=head2 suggestionid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier assigned automatically by Koha

=head2 suggestedby

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

borrowernumber for the person making the suggestion, foreign key linking to the borrowers table

=head2 suggesteddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

date the suggestion was submitted

=head2 managedby

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

borrowernumber for the librarian managing the suggestion, foreign key linking to the borrowers table

=head2 manageddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date the suggestion was updated

=head2 acceptedby

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

borrowernumber for the librarian who accepted the suggestion, foreign key linking to the borrowers table

=head2 accepteddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date the suggestion was marked as accepted

=head2 rejectedby

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

borrowernumber for the librarian who rejected the suggestion, foreign key linking to the borrowers table

=head2 rejecteddate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date the suggestion was marked as rejected

=head2 lastmodificationby

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

borrowernumber for the librarian who edit the suggestion for the last time

=head2 lastmodificationdate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date of the last modification

=head2 STATUS

  accessor: 'status'
  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

suggestion status (ASKED, CHECKED, ACCEPTED, REJECTED, ORDERED, AVAILABLE or a value from the SUGGEST_STATUS authorised value category)

=head2 archived

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

is the suggestion archived?

=head2 note

  data_type: 'longtext'
  is_nullable: 1

note entered on the suggestion

=head2 staff_note

  data_type: 'longtext'
  is_nullable: 1

non-public note entered on the suggestion

=head2 author

  data_type: 'varchar'
  is_nullable: 1
  size: 80

author of the suggested item

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 255

title of the suggested item

=head2 copyrightdate

  data_type: 'smallint'
  is_nullable: 1

copyright date of the suggested item

=head2 publishercode

  data_type: 'varchar'
  is_nullable: 1
  size: 255

publisher of the suggested item

=head2 date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

date and time the suggestion was updated

=head2 volumedesc

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 publicationyear

  data_type: 'smallint'
  default_value: 0
  is_nullable: 1

=head2 place

  data_type: 'varchar'
  is_nullable: 1
  size: 255

publication place of the suggested item

=head2 isbn

  data_type: 'varchar'
  is_nullable: 1
  size: 30

isbn of the suggested item

=head2 biblionumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key linking the suggestion to the biblio table after the suggestion has been ordered

=head2 reason

  data_type: 'mediumtext'
  is_nullable: 1

reason for accepting or rejecting the suggestion

=head2 patronreason

  data_type: 'mediumtext'
  is_nullable: 1

reason for making the suggestion

=head2 budgetid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

foreign key linking the suggested budget to the aqbudgets table

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

foreign key linking the suggested branch to the branches table

=head2 collectiontitle

  data_type: 'mediumtext'
  is_nullable: 1

collection name for the suggested item

=head2 itemtype

  data_type: 'varchar'
  is_nullable: 1
  size: 30

suggested item type

=head2 quantity

  data_type: 'smallint'
  is_nullable: 1

suggested quantity to be purchased

=head2 currency

  data_type: 'varchar'
  is_nullable: 1
  size: 10

suggested currency for the suggested price

=head2 price

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

suggested price

=head2 total

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

suggested total cost (price*quantity updated for currency)

=cut

__PACKAGE__->add_columns(
  "suggestionid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "suggestedby",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "suggesteddate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "managedby",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "manageddate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "acceptedby",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "accepteddate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "rejectedby",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "rejecteddate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "lastmodificationby",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "lastmodificationdate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "STATUS",
  {
    accessor => "status",
    data_type => "varchar",
    default_value => "",
    is_nullable => 0,
    size => 10,
  },
  "archived",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "note",
  { data_type => "longtext", is_nullable => 1 },
  "staff_note",
  { data_type => "longtext", is_nullable => 1 },
  "author",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "copyrightdate",
  { data_type => "smallint", is_nullable => 1 },
  "publishercode",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "volumedesc",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "publicationyear",
  { data_type => "smallint", default_value => 0, is_nullable => 1 },
  "place",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "isbn",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "biblionumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "reason",
  { data_type => "mediumtext", is_nullable => 1 },
  "patronreason",
  { data_type => "mediumtext", is_nullable => 1 },
  "budgetid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "collectiontitle",
  { data_type => "mediumtext", is_nullable => 1 },
  "itemtype",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "quantity",
  { data_type => "smallint", is_nullable => 1 },
  "currency",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "price",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "total",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
);

=head1 PRIMARY KEY

=over 4

=item * L</suggestionid>

=back

=cut

__PACKAGE__->set_primary_key("suggestionid");

=head1 RELATIONS

=head2 acceptedby

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "acceptedby",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "acceptedby" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 biblionumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Biblio>

=cut

__PACKAGE__->belongs_to(
  "biblionumber",
  "Koha::Schema::Result::Biblio",
  { biblionumber => "biblionumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 budgetid

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbudget>

=cut

__PACKAGE__->belongs_to(
  "budgetid",
  "Koha::Schema::Result::Aqbudget",
  { budget_id => "budgetid" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 lastmodificationby

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "lastmodificationby",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "lastmodificationby" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 managedby

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "managedby",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "managedby" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 rejectedby

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "rejectedby",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "rejectedby" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 suggestedby

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "suggestedby",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "suggestedby" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-09-07 20:40:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NSX5a0b7SJyhLVT8Fx4jaQ

__PACKAGE__->belongs_to(
  "suggester",
  "Koha::Schema::Result::Borrower",
  { "foreign.borrowernumber" => "self.suggestedby" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

__PACKAGE__->belongs_to(
    "manager",
    "Koha::Schema::Result::Borrower",
    { "foreign.borrowernumber" => "self.managedby" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "SET NULL",
        on_update     => "CASCADE",
    },
);

__PACKAGE__->belongs_to(
    "last_modifier",
    "Koha::Schema::Result::Borrower",
    { "foreign.borrowernumber" => "self.managedby" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "SET NULL",
        on_update     => "CASCADE",
    },
);

__PACKAGE__->belongs_to(
    "library",
    "Koha::Schema::Result::Branch",
    { "foreign.branchcode" => "self.branchcode" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "SET NULL",
        on_update     => "CASCADE",
    },
);

__PACKAGE__->belongs_to(
    "fund",
    "Koha::Schema::Result::Aqbudget",
    { budget_id => "budgetid" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "SET NULL",
        on_update     => "CASCADE",
    },
);

__PACKAGE__->add_columns(
    '+archived' => { is_boolean => 1 },
);

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Suggestions';
}

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Suggestion';
}

1;
