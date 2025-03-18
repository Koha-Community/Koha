use utf8;
package Koha::Schema::Result::Illcomment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Illcomment

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<illcomments>

=cut

__PACKAGE__->table("illcomments");

=head1 ACCESSORS

=head2 illcomment_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

Unique ID of the comment

=head2 illrequest_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

ILL request number

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

Link to the user who made the comment (could be librarian, patron or ILL partner library)

=head2 comment

  data_type: 'text'
  is_nullable: 1

The text of the comment

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

Date and time when the comment was made

=cut

__PACKAGE__->add_columns(
  "illcomment_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "illrequest_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "comment",
  { data_type => "text", is_nullable => 1 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</illcomment_id>

=back

=cut

__PACKAGE__->set_primary_key("illcomment_id");

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 illrequest

Type: belongs_to

Related object: L<Koha::Schema::Result::Illrequest>

=cut

__PACKAGE__->belongs_to(
  "illrequest",
  "Koha::Schema::Result::Illrequest",
  { illrequest_id => "illrequest_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:z5Y6mVTLtrYxmqmyAc/E7A

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::ILL::Comments';
}

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::ILL::Comment';
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
