use utf8;
package Koha::Schema::Result::AqbooksellerIssue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AqbooksellerIssue

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<aqbookseller_issues>

=cut

__PACKAGE__->table("aqbookseller_issues");

=head1 ACCESSORS

=head2 issue_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key and unique identifier assigned by Koha

=head2 vendor_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link to the vendor

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 80

type of the issue, authorised value VENDOR_ISSUE_TYPE

=head2 started_on

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

start of the issue

=head2 ended_on

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

end of the issue

=head2 notes

  data_type: 'longtext'
  is_nullable: 1

notes

=cut

__PACKAGE__->add_columns(
  "issue_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "vendor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "started_on",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "ended_on",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "notes",
  { data_type => "longtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</issue_id>

=back

=cut

__PACKAGE__->set_primary_key("issue_id");

=head1 RELATIONS

=head2 vendor

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqbookseller>

=cut

__PACKAGE__->belongs_to(
  "vendor",
  "Koha::Schema::Result::Aqbookseller",
  { id => "vendor_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-06-30 09:54:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ljn21/DFV5QvS5z3kDrBwQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
