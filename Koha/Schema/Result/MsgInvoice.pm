use utf8;
package Koha::Schema::Result::MsgInvoice;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MsgInvoice

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<msg_invoice>

=cut

__PACKAGE__->table("msg_invoice");

=head1 ACCESSORS

=head2 mi_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 msg_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 invoiceid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "mi_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "msg_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "invoiceid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</mi_id>

=back

=cut

__PACKAGE__->set_primary_key("mi_id");

=head1 RELATIONS

=head2 invoiceid

Type: belongs_to

Related object: L<Koha::Schema::Result::Aqinvoice>

=cut

__PACKAGE__->belongs_to(
  "invoiceid",
  "Koha::Schema::Result::Aqinvoice",
  { invoiceid => "invoiceid" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 msg

Type: belongs_to

Related object: L<Koha::Schema::Result::EdifactMessage>

=cut

__PACKAGE__->belongs_to(
  "msg",
  "Koha::Schema::Result::EdifactMessage",
  { id => "msg_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2014-09-02 11:37:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:F1jqlEH57dpxn2Pvm/vPGA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
