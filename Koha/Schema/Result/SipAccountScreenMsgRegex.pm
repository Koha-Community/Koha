use utf8;
package Koha::Schema::Result::SipAccountScreenMsgRegex;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SipAccountScreenMsgRegex

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<sip_account_screen_msg_regexs>

=cut

__PACKAGE__->table("sip_account_screen_msg_regexs");

=head1 ACCESSORS

=head2 sip_account_screen_msg_regex_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 sip_account_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

Foreign key to sip_accounts.sip_account_id

=head2 find

  data_type: 'varchar'
  is_nullable: 0
  size: 255

Regex find

=head2 replace

  data_type: 'varchar'
  is_nullable: 0
  size: 255

Regex replace

=cut

__PACKAGE__->add_columns(
  "sip_account_screen_msg_regex_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "sip_account_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "find",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "replace",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</sip_account_screen_msg_regex_id>

=back

=cut

__PACKAGE__->set_primary_key("sip_account_screen_msg_regex_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<sip_account>

=over 4

=item * L</sip_account_screen_msg_regex_id>

=item * L</sip_account_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "sip_account",
  ["sip_account_screen_msg_regex_id", "sip_account_id"],
);

=head1 RELATIONS

=head2 sip_account

Type: belongs_to

Related object: L<Koha::Schema::Result::SipAccount>

=cut

__PACKAGE__->belongs_to(
  "sip_account",
  "Koha::Schema::Result::SipAccount",
  { sip_account_id => "sip_account_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-02-06 17:50:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hn815lzqZnMYLS3b8NFB7w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
