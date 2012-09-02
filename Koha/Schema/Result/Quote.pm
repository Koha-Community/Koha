package Koha::Schema::Result::Quote;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Koha::Schema::Result::Quote

=cut

__PACKAGE__->table("quotes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 source

  data_type: 'text'
  is_nullable: 1

=head2 text

  data_type: 'mediumtext'
  is_nullable: 0

=head2 timestamp

  data_type: 'datetime'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "source",
  { data_type => "text", is_nullable => 1 },
  "text",
  { data_type => "mediumtext", is_nullable => 0 },
  "timestamp",
  { data_type => "datetime", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2012-09-02 08:44:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hvVwAMhaq9dIxuEMbWPNZA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
