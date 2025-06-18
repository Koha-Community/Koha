package Koha::Template::Plugin::NoticeTemplates;

# Copyright 2021 BibLibre
#
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

use Template::Plugin;
use base qw( Template::Plugin );

use Koha::Notice::Templates;

sub GetByModule {
    my ( $self, $module ) = @_;

    return Koha::Notice::Templates->search(
        { module => $module },
        {
            group_by => [ 'code', 'name' ],
            columns  => [ 'code', 'name' ],
            order_by => ['name']
        }
    );
}

=head1 NAME

Koha::Template::Plugin::NoticeTemplates - TT Plugin for notice templates

=head1 SYNOPSIS

[% USE NoticeTemplates %]

[% NoticeTemplates.GetByModule('members') %]

=head1 ROUTINES

=head2 GetByModule

In a template, you can get notice templates by module with
[% letters = NoticeTemplates.GetByModule( 'members' ) %]

=head1 AUTHOR

Alex Arnaud <alex.arnaud@biblibre.com>

=cut

1;
