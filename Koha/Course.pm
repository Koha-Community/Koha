package Koha::Course;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use base qw(Koha::Object);

=head1 NAME

Koha::Course - Koha Course Object class

=head2 Relations

=head3 instructors

  my $instructors = $course->instructors();

Returns the related Koha::Patrons object containing the instructors for this course

=cut

sub instructors {
    my ($self) = @_;

    my $instructors = Koha::Patrons->search(
        { 'course_instructors.course_id' => $self->course_id },
        { join                           => 'course_instructors' }
    );

    return $instructors;
}

=head2 Internal methods

=cut

=head3 _type

=cut

sub _type {
    return 'Course';
}

1;
