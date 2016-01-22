use utf8;
package Koha::Schema::Result::BorrowerPasswordRecovery;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::BorrowerPasswordRecovery

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<borrower_password_recovery>

=cut

__PACKAGE__->table("borrower_password_recovery");

=head1 ACCESSORS

=head2 borrowernumber

  data_type: 'integer'
  is_nullable: 0

=head2 uuid

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=head2 valid_until

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "borrowernumber",
  { data_type => "integer", is_nullable => 0 },
  "uuid",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "valid_until",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</borrowernumber>

=back

=cut

__PACKAGE__->set_primary_key("borrowernumber");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2016-01-22 10:16:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:c4ehAGqOD6YHpGg85BX8YQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

1;
