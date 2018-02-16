use utf8;
package Koha::Schema::Result::Quote;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Quote

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<quotes>

=cut

__PACKAGE__->table("quotes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 source

  data_type: 'mediumtext'
  is_nullable: 1

=head2 text

  data_type: 'longtext'
  is_nullable: 0

=head2 timestamp

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "source",
  { data_type => "mediumtext", is_nullable => 1 },
  "text",
  { data_type => "longtext", is_nullable => 0 },
  "timestamp",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8xSMrGuJH9rbm73qOvU8Xg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
