use utf8;
package Koha::Schema::Result::ImportRecordMatch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::ImportRecordMatch

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<import_record_matches>

=cut

__PACKAGE__->table("import_record_matches");

=head1 ACCESSORS

=head2 import_record_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

the id given to the imported bib record (import_records.import_record_id)

=head2 candidate_match_id

  data_type: 'integer'
  is_nullable: 0

the biblio the imported record matches (biblio.biblionumber)

=head2 score

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

the match score

=cut

__PACKAGE__->add_columns(
  "import_record_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "candidate_match_id",
  { data_type => "integer", is_nullable => 0 },
  "score",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 RELATIONS

=head2 import_record

Type: belongs_to

Related object: L<Koha::Schema::Result::ImportRecord>

=cut

__PACKAGE__->belongs_to(
  "import_record",
  "Koha::Schema::Result::ImportRecord",
  { import_record_id => "import_record_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kWU/SGWvZBBvVwEvDysrtA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
