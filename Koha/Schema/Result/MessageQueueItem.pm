package Koha::Schema::Result::MessageQueueItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::MessageQueueItem

=cut

__PACKAGE__->table("message_queue_items");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 issue_id

  data_type: 'integer'
  is_nullable: 1

=head2 letternumber

  data_type: 'integer'
  is_nullable: 1

=head2 itemnumber

  data_type: 'integer'
  is_nullable: 0

=head2 branch

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 message_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "issue_id",
  { data_type => "integer", is_nullable => 1 },
  "letternumber",
  { data_type => "integer", is_nullable => 1 },
  "itemnumber",
  { data_type => "integer", is_nullable => 0 },
  "branch",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "message_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("no_duplicate_item_per_message", ["message_id", "itemnumber"]);

=head1 RELATIONS

=head2 message

Type: belongs_to

Related object: L<Koha::Schema::Result::MessageQueue>

=cut

__PACKAGE__->belongs_to(
  "message",
  "Koha::Schema::Result::MessageQueue",
  { message_id => "message_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2015-05-27 18:13:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kj2ZEAd+c3y3WpPZY047yQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
