use utf8;
package Koha::Schema::Result::Atomicupdate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Atomicupdate

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<atomicupdates>

=cut

__PACKAGE__->table("atomicupdates");

=head1 ACCESSORS

=head2 atomicupdate_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 issue_id

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 filename

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=head2 modification_time

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: 'current_timestamp()'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "atomicupdate_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "issue_id",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "filename",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "modification_time",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "current_timestamp()",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</atomicupdate_id>

=back

=cut

__PACKAGE__->set_primary_key("atomicupdate_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<atomic_issue_id>

=over 4

=item * L</issue_id>

=back

=cut

__PACKAGE__->add_unique_constraint("atomic_issue_id", ["issue_id"]);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-08-20 11:50:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1wWCGsQhplzyRAKdwAOhoA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
