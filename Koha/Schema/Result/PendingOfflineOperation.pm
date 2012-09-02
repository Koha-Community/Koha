package Koha::Schema::Result::PendingOfflineOperation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::PendingOfflineOperation

=cut

__PACKAGE__->table("pending_offline_operations");

=head1 ACCESSORS

=head2 operationid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 userid

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=head2 branchcode

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 timestamp

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0

=head2 action

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 barcode

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 cardnumber

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=cut

__PACKAGE__->add_columns(
  "operationid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "userid",
  { data_type => "varchar", is_nullable => 0, size => 30 },
  "branchcode",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "timestamp",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "action",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "barcode",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "cardnumber",
  { data_type => "varchar", is_nullable => 1, size => 16 },
);
__PACKAGE__->set_primary_key("operationid");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PFEH3bfCYOG8Q3dOX/IQ5w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
