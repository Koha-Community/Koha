use utf8;
package Koha::Schema::Result::PreservationProcessing;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PreservationProcessing

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<preservation_processings>

=cut

__PACKAGE__->table("preservation_processings");

=head1 ACCESSORS

=head2 processing_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

primary key

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 80

name of the processing

=head2 letter_code

  data_type: 'varchar'
  is_nullable: 1
  size: 20

Foreign key to the letters table

=cut

__PACKAGE__->add_columns(
  "processing_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "letter_code",
  { data_type => "varchar", is_nullable => 1, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</processing_id>

=back

=cut

__PACKAGE__->set_primary_key("processing_id");

=head1 RELATIONS

=head2 preservation_processing_attributes

Type: has_many

Related object: L<Koha::Schema::Result::PreservationProcessingAttribute>

=cut

__PACKAGE__->has_many(
  "preservation_processing_attributes",
  "Koha::Schema::Result::PreservationProcessingAttribute",
  { "foreign.processing_id" => "self.processing_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 preservation_trains

Type: has_many

Related object: L<Koha::Schema::Result::PreservationTrain>

=cut

__PACKAGE__->has_many(
  "preservation_trains",
  "Koha::Schema::Result::PreservationTrain",
  { "foreign.default_processing_id" => "self.processing_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 preservation_trains_items

Type: has_many

Related object: L<Koha::Schema::Result::PreservationTrainsItem>

=cut

__PACKAGE__->has_many(
  "preservation_trains_items",
  "Koha::Schema::Result::PreservationTrainsItem",
  { "foreign.processing_id" => "self.processing_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2023-04-17 18:58:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fIZfFuAY21nh+Fwwjd/kJw

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Preservation::Processing';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Preservation::Processings';
}

1;
