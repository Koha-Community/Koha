use utf8;
package Koha::Schema::Result::Overduebill;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Overduebill

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<overduebills>

=cut

__PACKAGE__->table("overduebills");

=head1 ACCESSORS

=head2 bill_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 issue_id

  data_type: 'integer'
  is_nullable: 0

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: 'current_timestamp()'
  is_nullable: 0

=head2 billingdate

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "bill_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "issue_id",
  { data_type => "integer", is_nullable => 0 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "current_timestamp()",
    is_nullable => 0,
  },
  "billingdate",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</bill_id>

=back

=cut

__PACKAGE__->set_primary_key("bill_id");


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-08-20 11:50:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SUe6fQXWubhENaW7thABww


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
