package Koha::Template::Plugin::HtmlScrubber;

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
use base 'Template::Plugin::Filter';

use C4::Scrubber;

sub init {
    my $self = shift;
    my $name = 'scrub_html';
    $self->{_DYNAMIC} = 1;
    $self->install_filter($name);
    $self->{cached_filters} = {};
    return $self;
}

sub filter {
    my ( $self, $text, $args, $config ) = @_;
    my $type = $config->{type} || 'default';
    if ($type) {
        if ( !$self->{cached_filters}->{$type} ) {
            my $new_scrubber = C4::Scrubber->new($type);
            if ($new_scrubber) {
                $self->{cached_filters}->{$type} = $new_scrubber;
            }
        }
        my $scrubber = $self->{cached_filters}->{$type};
        if ($scrubber) {
            my $scrubbed = $scrubber->scrub($text);
            return $scrubbed;
        }
    }

    #NOTE: If you don't have a scrubber, just return what was passed in
    return $text;
}

1;

=head1 NAME

Koha::Template::Plugin::HtmlScrubber - TT plugin for scrubbing HTML to limited elements and attributes

=head1 SYNOPSIS

[% USE HtmlScrubber %]

[% content.note | scrub_html type => 'note' %]

This filter scrubs HTML using profiles predefined in C4::Scrubber

=head1 METHODS

=head2 init

This method installs the filter name and declares it as a dynamic filter

=head2 filter

Returns a scrubbed version of HTML content

=cut
