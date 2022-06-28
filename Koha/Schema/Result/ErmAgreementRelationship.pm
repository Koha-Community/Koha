use utf8;
package Koha::Schema::Result::ErmAgreementRelationship;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ErmAgreementRelationship

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erm_agreement_relationships>

=cut

__PACKAGE__->table("erm_agreement_relationships");

=head1 ACCESSORS

=head2 agreement_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link to the agreement

=head2 related_agreement_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

link to the related agreement

=head2 relationship

  data_type: 'enum'
  extra: {list => ["supersedes","is-superseded-by","provides_post-cancellation_access_for","has-post-cancellation-access-in","tracks_demand-driven_acquisitions_for","has-demand-driven-acquisitions-in","has_backfile_in","has_frontfile_in","related_to"]}
  is_nullable: 0

relationship between the two agreements

=head2 notes

  data_type: 'mediumtext'
  is_nullable: 1

notes about this relationship

=cut

__PACKAGE__->add_columns(
  "agreement_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "related_agreement_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "relationship",
  {
    data_type => "enum",
    extra => {
      list => [
        "supersedes",
        "is-superseded-by",
        "provides_post-cancellation_access_for",
        "has-post-cancellation-access-in",
        "tracks_demand-driven_acquisitions_for",
        "has-demand-driven-acquisitions-in",
        "has_backfile_in",
        "has_frontfile_in",
        "related_to",
      ],
    },
    is_nullable => 0,
  },
  "notes",
  { data_type => "mediumtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</agreement_id>

=item * L</related_agreement_id>

=back

=cut

__PACKAGE__->set_primary_key("agreement_id", "related_agreement_id");

=head1 RELATIONS

=head2 agreement

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmAgreement>

=cut

__PACKAGE__->belongs_to(
  "agreement",
  "Koha::Schema::Result::ErmAgreement",
  { agreement_id => "agreement_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 related_agreement

Type: belongs_to

Related object: L<Koha::Schema::Result::ErmAgreement>

=cut

__PACKAGE__->belongs_to(
  "related_agreement",
  "Koha::Schema::Result::ErmAgreement",
  { agreement_id => "related_agreement_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-05-25 11:46:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EYK21+2xV7p1yCXR8OFKIA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
