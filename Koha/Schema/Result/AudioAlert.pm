use utf8;
package Koha::Schema::Result::AudioAlert;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AudioAlert

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<audio_alerts>

=cut

__PACKAGE__->table("audio_alerts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 precedence

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 selector

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 sound

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "precedence",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "selector",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "sound",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2015-08-19 08:01:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lPTnmrJd5V/X9fLebC8FHA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
