use utf8;
package Koha::Schema::Result::OauthAccessToken;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::OauthAccessToken

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<oauth_access_tokens>

=cut

__PACKAGE__->table("oauth_access_tokens");

=head1 ACCESSORS

=head2 access_token

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 client_id

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 expires

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "access_token",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "client_id",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "expires",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</access_token>

=back

=cut

__PACKAGE__->set_primary_key("access_token");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-04-11 17:44:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:u2e++Jrwln4Qhi3UPx2CQA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
