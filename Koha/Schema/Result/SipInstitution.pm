use utf8;
package Koha::Schema::Result::SipInstitution;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::SipInstitution

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<sip_institutions>

=cut

__PACKAGE__->table("sip_institutions");

=head1 ACCESSORS

=head2 sip_institution_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 80

Unique varchar identifier. Previously "id" in SIPconfig.xml

=head2 implementation

  data_type: 'varchar'
  default_value: 'ILS'
  is_nullable: 0
  size: 80

=head2 checkin

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

Previously attribute of "policy" in SIPconfig.xml

=head2 checkout

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

Previously attribute of "policy" in SIPconfig.xml

=head2 offline

  data_type: 'tinyint'
  is_nullable: 1

Previously attribute of "policy" in SIPconfig.xml

=head2 renewal

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Previously attribute of "policy" in SIPconfig.xml

=head2 retries

  data_type: 'integer'
  default_value: 5
  is_nullable: 0

Previously attribute of "policy" in SIPconfig.xml

=head2 status_update

  data_type: 'tinyint'
  is_nullable: 1

Previously attribute of "policy" in SIPconfig.xml

=head2 timeout

  data_type: 'integer'
  default_value: 100
  is_nullable: 0

Previously attribute of "policy" in SIPconfig.xml

=cut

__PACKAGE__->add_columns(
  "sip_institution_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "implementation",
  {
    data_type => "varchar",
    default_value => "ILS",
    is_nullable => 0,
    size => 80,
  },
  "checkin",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "checkout",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "offline",
  { data_type => "tinyint", is_nullable => 1 },
  "renewal",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "retries",
  { data_type => "integer", default_value => 5, is_nullable => 0 },
  "status_update",
  { data_type => "tinyint", is_nullable => 1 },
  "timeout",
  { data_type => "integer", default_value => 100, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</sip_institution_id>

=back

=cut

__PACKAGE__->set_primary_key("sip_institution_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<institution_name>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("institution_name", ["name"]);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-10-10 15:04:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5QP4sj2sL+LQ+uc8+WCG6A

__PACKAGE__->add_columns(
    '+checkin' => { is_boolean => 1 }
);

__PACKAGE__->add_columns(
    "+checkout" => { is_boolean => 1 }
);

__PACKAGE__->add_columns(
    "+offline" => { is_boolean => 1 }
);

__PACKAGE__->add_columns(
    "+renewal" => { is_boolean => 1 }
);

__PACKAGE__->add_columns(
    "+status_update" => { is_boolean => 1 }
);

sub koha_objects_class {
    'Koha::SIP2::Institutions';
}
sub koha_object_class {
    'Koha::SIP2::Institution';
}

1;
