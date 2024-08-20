package Koha::Template::Plugin::SafeURL;

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use URI;
use base 'Template::Plugin::Filter';

sub init {
    my $self = shift;
    my $name = 'safe_url';
    $self->{_DYNAMIC} = 1;
    $self->install_filter($name);
    return $self;
}

sub filter {
    my ( $self, $text, $args, $config ) = @_;
    my $uri = URI->new($text);
    if ($uri) {
        return $uri;
    }

    #NOTE: If it isn't a real URL, just return a safe fragment
    return '#';
}

1;

=head1 NAME

Koha::Template::Plugin::SafeURL - TT Plugin for filtering whole URLs

=head1 SYNOPSIS

[% USE SafeURL %]

[% $url | safe_url %]

This filter parses the text as a URL and returns the object which
is stringified in a safe format.

=head1 METHODS

=head2 init

This method installs the filter name and declares it as a dynamic filter

=head2 filter

Returns a stringified version of a Perl URL object

=cut
