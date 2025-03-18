use utf8;
package Koha::Schema::Result::Systempreference;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Systempreference

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<systempreferences>

=cut

__PACKAGE__->table("systempreferences");

=head1 ACCESSORS

=head2 variable

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 50

system preference name

=head2 value

  data_type: 'mediumtext'
  is_nullable: 1

system preference values

=head2 options

  data_type: 'longtext'
  is_nullable: 1

options for multiple choice system preferences

=head2 explanation

  data_type: 'mediumtext'
  is_nullable: 1

descriptive text for the system preference

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 20

type of question this preference asks (multiple choice, plain text, yes or no, etc)

=cut

__PACKAGE__->add_columns(
  "variable",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "value",
  { data_type => "mediumtext", is_nullable => 1 },
  "options",
  { data_type => "longtext", is_nullable => 1 },
  "explanation",
  { data_type => "mediumtext", is_nullable => 1 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</variable>

=back

=cut

__PACKAGE__->set_primary_key("variable");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-21 13:39:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:d9V4/gPRw1ucbd/TzEzNUQ

=head2 koha_object_class

Missing POD for koha_object_class.

=cut

sub koha_object_class {
    'Koha::Config::SysPref';
}

=head2 koha_objects_class

Missing POD for koha_objects_class.

=cut

sub koha_objects_class {
    'Koha::Config::SysPrefs';
}

1;
