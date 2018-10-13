use utf8;
package Koha::Schema::Result::Illrequestattribute;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Illrequestattribute

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<illrequestattributes>

=cut

__PACKAGE__->table("illrequestattributes");

=head1 ACCESSORS

=head2 illrequest_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 type

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 value

  data_type: 'mediumtext'
  is_nullable: 0

=head2 readonly

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "illrequest_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "type",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "value",
  { data_type => "mediumtext", is_nullable => 0 },
  "readonly",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</illrequest_id>

=item * L</type>

=back

=cut

__PACKAGE__->set_primary_key("illrequest_id", "type");

=head1 RELATIONS

=head2 illrequest

Type: belongs_to

Related object: L<Koha::Schema::Result::Illrequest>

=cut

__PACKAGE__->belongs_to(
  "illrequest",
  "Koha::Schema::Result::Illrequest",
  { illrequest_id => "illrequest_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-05-17 09:17:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sFY1giVMz5AkXCPidhyGjw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
