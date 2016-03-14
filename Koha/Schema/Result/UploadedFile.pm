use utf8;
package Koha::Schema::Result::UploadedFile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::UploadedFile

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<uploaded_files>

=cut

__PACKAGE__->table("uploaded_files");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 hashvalue

  data_type: 'char'
  is_nullable: 0
  size: 40

=head2 filename

  data_type: 'text'
  is_nullable: 0

=head2 dir

  data_type: 'text'
  is_nullable: 0

=head2 filesize

  data_type: 'integer'
  is_nullable: 1

=head2 dtcreated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 uploadcategorycode

  data_type: 'tinytext'
  is_nullable: 1

=head2 owner

  data_type: 'integer'
  is_nullable: 1

=head2 public

  data_type: 'tinyint'
  is_nullable: 1

=head2 permanent

  data_type: 'tinyint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "hashvalue",
  { data_type => "char", is_nullable => 0, size => 40 },
  "filename",
  { data_type => "text", is_nullable => 0 },
  "dir",
  { data_type => "text", is_nullable => 0 },
  "filesize",
  { data_type => "integer", is_nullable => 1 },
  "dtcreated",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "uploadcategorycode",
  { data_type => "tinytext", is_nullable => 1 },
  "owner",
  { data_type => "integer", is_nullable => 1 },
  "public",
  { data_type => "tinyint", is_nullable => 1 },
  "permanent",
  { data_type => "tinyint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-09-25 15:20:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Cq/HSuTaBxZH2qSGEddoaQ


sub allows_add_by {
    my ( $self, $userid ) = @_; # do not confuse with borrowernumber
    my $flags = [
        { tools      => 'upload_general_files' },
        { circulate  => 'circulate_remaining_permissions' },
        { tools      => 'stage_marc_import' },
        { tools      => 'upload_local_cover_images' },
    ];
    require C4::Auth;
    foreach( @$flags ) {
        return 1 if C4::Auth::haspermission( $userid, $_ );
    }
    return;
}

1;
