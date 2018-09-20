use utf8;
package Koha::Schema::Result::PatronConsent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::PatronConsent

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<patron_consent>

=cut

__PACKAGE__->table("patron_consent");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 type

  data_type: 'enum'
  extra: {list => ["GDPR_PROCESSING"]}
  is_nullable: 1

=head2 given_on

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 refused_on

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "type",
  {
    data_type => "enum",
    extra => { list => ["GDPR_PROCESSING"] },
    is_nullable => 1,
  },
  "given_on",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "refused_on",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2018-09-20 13:00:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:as3b13eS31zkIPr9uxP7+A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
