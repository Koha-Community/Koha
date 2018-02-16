use utf8;
package Koha::Schema::Result::MarcModificationTemplate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::MarcModificationTemplate

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<marc_modification_templates>

=cut

__PACKAGE__->table("marc_modification_templates");

=head1 ACCESSORS

=head2 template_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'mediumtext'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "template_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "mediumtext", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</template_id>

=back

=cut

__PACKAGE__->set_primary_key("template_id");

=head1 RELATIONS

=head2 marc_modification_template_actions

Type: has_many

Related object: L<Koha::Schema::Result::MarcModificationTemplateAction>

=cut

__PACKAGE__->has_many(
  "marc_modification_template_actions",
  "Koha::Schema::Result::MarcModificationTemplateAction",
  { "foreign.template_id" => "self.template_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-02-16 17:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bu3u1X0RBx4c35kkph05/A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
