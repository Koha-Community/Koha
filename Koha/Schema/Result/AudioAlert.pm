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

=head2 audio_alert_id

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
  "audio_alert_id",
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

=item * L</audio_alert_id>

=back

=cut

__PACKAGE__->set_primary_key("audio_alert_id");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-12-22 01:04:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yIXpJMcpovBDl3bBVrwLqg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
