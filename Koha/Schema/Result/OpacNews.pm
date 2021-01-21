use utf8;
package Koha::Schema::Result::OpacNews;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::OpacNews

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<opac_news>

=cut

__PACKAGE__->table("opac_news");

=head1 ACCESSORS

=head2 idnew

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

unique identifier for the news article

=head2 branchcode

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 10

branch code users to create branch specific news, NULL is every branch.

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 250

title of the news article

=head2 content

  data_type: 'mediumtext'
  is_nullable: 0

the body of your news article

=head2 lang

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 50

location for the article (koha is the staff interface, slip is the circulation receipt and language codes are for the opac)

=head2 published_on

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

publication date

=head2 updated_on

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

last modification

=head2 expirationdate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

date the article is set to expire or no longer be visible

=head2 number

  data_type: 'integer'
  is_nullable: 1

the order in which this article appears in that specific location

=head2 borrowernumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

The user who created the news article

=cut

__PACKAGE__->add_columns(
  "idnew",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "branchcode",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 10 },
  "title",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 250 },
  "content",
  { data_type => "mediumtext", is_nullable => 0 },
  "lang",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "published_on",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "updated_on",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "expirationdate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "number",
  { data_type => "integer", is_nullable => 1 },
  "borrowernumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</idnew>

=back

=cut

__PACKAGE__->set_primary_key("idnew");

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 branchcode

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "branchcode",
  "Koha::Schema::Result::Branch",
  { branchcode => "branchcode" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Edd8K7ANL49fG7FKjwyRVQ

sub koha_object_class {
    'Koha::NewsItem';
}
sub koha_objects_class {
    'Koha::News';
}

1;
