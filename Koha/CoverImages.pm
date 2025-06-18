package Koha::CoverImages;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Database;

use Koha::CoverImage;

use base qw(Koha::Objects);

=head1 NAME

Koha::CoverImages - Koha CoverImage Object set class

=head1 API

=head2 Class Methods

=cut

=head3 no_image

Returns the gif to be used when there is no image.
Its mimetype is image/gif.

=cut

sub no_image {
    my $no_image = pack(
        "H*",
        '47494638396101000100800000FFFFFF' . '00000021F90401000000002C00000000' . '010001000002024401003B'
    );
    return Koha::CoverImage->new(
        {
            mimetype  => 'image/gif',
            imagefile => $no_image,
            thumbnail => $no_image,
        }
    );
}

=head3 _type

=cut

sub _type {
    return 'CoverImage';
}

=head2 object_class

Missing POD for object_class.

=cut

sub object_class {
    return 'Koha::CoverImage';
}

1;
