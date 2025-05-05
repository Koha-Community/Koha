use utf8;
package Koha::Schema::Result::TagsApproval;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::TagsApproval

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<tags_approval>

=cut

__PACKAGE__->table("tags_approval");

=head1 ACCESSORS

=head2 term

  data_type: 'varchar'
  is_nullable: 0
  size: 191

the tag

=head2 approved

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

whether the tag is approved or not (1=yes, 0=pending, -1=rejected)

=head2 date_approved

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

the date this tag was approved

=head2 approved_by

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

the librarian who approved the tag (borrowers.borrowernumber)

=head2 weight_total

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

the total number of times this tag was used

=cut

__PACKAGE__->add_columns(
  "term",
  { data_type => "varchar", is_nullable => 0, size => 191 },
  "approved",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "date_approved",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "approved_by",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "weight_total",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</term>

=back

=cut

__PACKAGE__->set_primary_key("term");

=head1 RELATIONS

=head2 approved_by

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "approved_by",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "approved_by" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 tags_indexes

Type: has_many

Related object: L<Koha::Schema::Result::TagsIndex>

=cut

__PACKAGE__->has_many(
  "tags_indexes",
  "Koha::Schema::Result::TagsIndex",
  { "foreign.term" => "self.term" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PR7rfXKXExWpmkdxcXRrbQ

__PACKAGE__->add_columns(
    '+approved' => { is_boolean => 0 },
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Tags::Approval';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Tags::Approvals';
}

1;
