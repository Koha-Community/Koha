use utf8;
package Koha::Schema::Result::ProblemReport;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ProblemReport

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<problem_reports>

=cut

__PACKAGE__->table("problem_reports");

=head1 ACCESSORS

=head2 reportid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

unique identifier assigned by Koha

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 40

report subject line

=head2 content

  data_type: 'text'
  is_nullable: 0

report message content

=head2 borrowernumber

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

the user who created the problem report

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 0
  size: 10

borrower's branch

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 75

OPAC username

=head2 problempage

  data_type: 'text'
  is_nullable: 1

page the user triggered the problem report form from

=head2 recipient

  data_type: 'enum'
  default_value: 'library'
  extra: {list => ["admin","library"]}
  is_nullable: 0

the 'to-address' of the problem report

=head2 created_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

timestamp of report submission

=head2 status

  data_type: 'varchar'
  default_value: 'New'
  is_nullable: 0
  size: 6

status of the report. New, Viewed, Closed

=cut

__PACKAGE__->add_columns(
  "reportid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "title",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 40 },
  "content",
  { data_type => "text", is_nullable => 0 },
  "borrowernumber",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "branchcode",
  {
    data_type => "varchar",
    default_value => "",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 10,
  },
  "username",
  { data_type => "varchar", is_nullable => 1, size => 75 },
  "problempage",
  { data_type => "text", is_nullable => 1 },
  "recipient",
  {
    data_type => "enum",
    default_value => "library",
    extra => { list => ["admin", "library"] },
    is_nullable => 0,
  },
  "created_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "status",
  { data_type => "varchar", default_value => "New", is_nullable => 0, size => 6 },
);

=head1 PRIMARY KEY

=over 4

=item * L</reportid>

=back

=cut

__PACKAGE__->set_primary_key("reportid");

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

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2021-04-12 13:27:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YdCX1Hak6UwiJo1iBJqqzg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
