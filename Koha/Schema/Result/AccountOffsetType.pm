use utf8;
package Koha::Schema::Result::AccountOffsetType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AccountOffsetType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<account_offset_types>

=cut

__PACKAGE__->table("account_offset_types");

=head1 ACCESSORS

=head2 type

  data_type: 'varchar'
  is_nullable: 0
  size: 16

=cut

__PACKAGE__->add_columns(
  "type",
  { data_type => "varchar", is_nullable => 0, size => 16 },
);

=head1 PRIMARY KEY

=over 4

=item * L</type>

=back

=cut

__PACKAGE__->set_primary_key("type");

=head1 RELATIONS

=head2 account_offsets

Type: has_many

Related object: L<Koha::Schema::Result::AccountOffset>

=cut

__PACKAGE__->has_many(
  "account_offsets",
  "Koha::Schema::Result::AccountOffset",
  { "foreign.type" => "self.type" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2017-10-20 16:27:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rPRWMfAfRke3jGG3iISi2A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
