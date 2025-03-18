use utf8;
package Koha::Schema::Result::PreservationTrain;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PreservationTrain

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<preservation_trains>

=cut

__PACKAGE__->table("preservation_trains");

=head1 ACCESSORS

=head2 train_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 80

name of the train

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

description of the train

=head2 default_processing_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

default processing, link to preservation_processings.processing_id

=head2 not_for_loan

  data_type: 'varchar'
  default_value: 0
  is_nullable: 0
  size: 80

NOT_LOAN authorised value to apply toitem added to this train

=head2 created_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

creation date

=head2 closed_on

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

closing date

=head2 sent_on

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

sending date

=head2 received_on

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

receiving date

=cut

__PACKAGE__->add_columns(
  "train_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "default_processing_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "not_for_loan",
  { data_type => "varchar", default_value => 0, is_nullable => 0, size => 80 },
  "created_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "closed_on",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "sent_on",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "received_on",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</train_id>

=back

=cut

__PACKAGE__->set_primary_key("train_id");

=head1 RELATIONS

=head2 default_processing

Type: belongs_to

Related object: L<Koha::Schema::Result::PreservationProcessing>

=cut

__PACKAGE__->belongs_to(
  "default_processing",
  "Koha::Schema::Result::PreservationProcessing",
  { processing_id => "default_processing_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 preservation_trains_items

Type: has_many

Related object: L<Koha::Schema::Result::PreservationTrainsItem>

=cut

__PACKAGE__->has_many(
  "preservation_trains_items",
  "Koha::Schema::Result::PreservationTrainsItem",
  { "foreign.train_id" => "self.train_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-04-17 18:47:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ojxQ0wFj2datCPVjeuTBWw

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Preservation::Train';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Preservation::Trains';
}

1;
