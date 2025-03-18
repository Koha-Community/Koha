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
  size: 191

generarated access token

=head2 client_id

  data_type: 'varchar'
  is_nullable: 0
  size: 191

the client id the access token belongs to

=head2 expires

  data_type: 'integer'
  is_nullable: 0

expiration time in seconds

=cut

__PACKAGE__->add_columns(
  "access_token",
  { data_type => "varchar", is_nullable => 0, size => 191 },
  "client_id",
  { data_type => "varchar", is_nullable => 0, size => 191 },
  "expires",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</access_token>

=back

=cut

__PACKAGE__->set_primary_key("access_token");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3mL1s811AK45Nn5yPSJSaA

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::OAuthAccessToken';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::OAuthAccessTokens';
}

1;
