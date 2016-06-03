use utf8;
package Koha::Schema::Result::RefundLostItemFeeRule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::RefundLostItemFeeRule

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<refund_lost_item_fee_rules>

=cut

__PACKAGE__->table("refund_lost_item_fee_rules");

=head1 ACCESSORS

=head2 branchcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 refund

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "branchcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "refund",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</branchcode>

=back

=cut

__PACKAGE__->set_primary_key("branchcode");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-05-31 02:45:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:K+2D3R+JxrovgvjdqA8xdw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
