use utf8;
package Koha::Schema::Result::HoldCancellationRequest;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::HoldCancellationRequest

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<hold_cancellation_requests>

=cut

__PACKAGE__->table("hold_cancellation_requests");

=head1 ACCESSORS

=head2 hold_cancellation_request_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

Unique ID of the cancellation request

=head2 hold_id

  data_type: 'integer'
  is_nullable: 0

ID of the hold

=head2 creation_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

Time and date the cancellation request was created

=cut

__PACKAGE__->add_columns(
  "hold_cancellation_request_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "hold_id",
  { data_type => "integer", is_nullable => 0 },
  "creation_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</hold_cancellation_request_id>

=back

=cut

__PACKAGE__->set_primary_key("hold_cancellation_request_id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-08 14:24:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:g+XrDWjaRri+Y0TESDFuBQ

# FIXME: Revisit after bug 25260
__PACKAGE__->might_have(
    "hold",
    "Koha::Schema::Result::Reserve",
    { "foreign.reserve_id" => "self.hold_id" },
    { cascade_copy       => 0, cascade_delete => 0 },
);

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Hold::CancellationRequest';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Hold::CancellationRequests';
}

1;
