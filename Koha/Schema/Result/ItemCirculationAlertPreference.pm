package Koha::Schema::Result::ItemCirculationAlertPreference;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::ItemCirculationAlertPreference

=cut

__PACKAGE__->table("item_circulation_alert_preferences");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 branchcode

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 categorycode

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 item_type

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 notification

  data_type: 'varchar'
  is_nullable: 0
  size: 16

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "branchcode",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "categorycode",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "item_type",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "notification",
  { data_type => "varchar", is_nullable => 0, size => 16 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:u0W8zw5k/6shlotWbr/5UA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
