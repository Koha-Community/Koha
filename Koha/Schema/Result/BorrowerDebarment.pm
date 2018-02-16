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

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 expiration

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 type

  data_type: 'enum'
  default_value: 'MANUAL'
  extra: {list => ["SUSPENSION","OVERDUES","MANUAL","DISCHARGE"]}
  is_nullable: 0

=head2 comment

  data_type: 'mediumtext'
  is_nullable: 1

=head2 manager_id

  data_type: 'integer'
  is_nullable: 1

=head2 created

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 updated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "borrower_debarment_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "expiration",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "type",
  {
    data_type => "enum",
    default_value => "MANUAL",
    extra => { list => ["SUSPENSION", "OVERDUES", "MANUAL", "DISCHARGE"] },
    is_nullable => 0,
  },
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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:J9J1ReRLqhVasOQXvde2Uw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
