package C4::Scrubber;

# Copyright Liblime 2008
# Parts copyright sys-tech.net 2011
# Copyright PTFS Europe 2011
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

use strict;
use warnings;
use Carp qw( croak );
use HTML::Scrubber;

use C4::Context;

my %scrubbertypes = (
    default        => {},    # place holder, default settings are below as fallbacks in call to constructor
    comment        => { allow => [qw( br b i em big small strong )], },
    note           => { allow => [qw[ br b i em big small strong u hr span div p ol ul li dl dt dd ]] },
    record_display => {
        allow => [
            qw(
                div span h1 h2 h3 h4 h5 h6 p br
                ul ol li dl dt dd
                a img
                strong b em i u s strike del ins sup sub
                blockquote cite q abbr acronym dfn
                table thead tbody tfoot tr td th caption
                pre code kbd samp var
                hr
                address
            )
        ],
        rules => [
            div => {
                class => qr/^[\w\s\-_]+$/,
                id    => qr/^[\w\-_]+$/,
            },

            span => {
                class => qr/^[\w\s\-_]+$/,
                id    => qr/^[\w\-_]+$/,
            },

            p => {
                class => qr/^[\w\s\-_]+$/,
                id    => qr/^[\w\-_]+$/,
            },

            a => {
                href   => qr{^(?:https?://|/cgi-bin/|mailto:|#)}i,
                class  => qr/^[\w\s\-_]+$/,
                title  => 1,
                target => qr/^_(?:blank|self|parent|top)$/,
            },

            ul => {
                class => qr/^[\w\s\-_]+$/,
                id    => qr/^[\w\-_]+$/,
            },

            ol => {
                class => qr/^[\w\s\-_]+$/,
                id    => qr/^[\w\-_]+$/,
            },

            li => {
                class => qr/^[\w\s\-_]+$/,
                id    => qr/^[\w\-_]+$/,
            },

            i => {
                class        => qr/^[\w\s\-_]+$/,
                'aria-label' => 1,
            },
        ],
    },
);

sub new {
    shift;    # ignore our class we are wrapper
    my $type = (@_) ? shift : 'default';
    $type = 'default' if !defined $type;
    if ( !exists $scrubbertypes{$type} ) {
        croak "New called with unrecognized type '$type'";
    }
    my $settings = $scrubbertypes{$type};
    my $scrubber = HTML::Scrubber->new(
        allow   => exists $settings->{allow}   ? $settings->{allow}   : [],
        rules   => exists $settings->{rules}   ? $settings->{rules}   : [],
        default => exists $settings->{default} ? $settings->{default} : [ 0 => { '*' => 0 } ],
        comment => exists $settings->{comment} ? $settings->{comment} : 0,
        process => 0,
    );
    return $scrubber;
}

1;
__END__

=head1 C4::Sanitize

Standardized wrapper with settings for building HTML::Scrubber tailored to various koha inputs.

The default is to scrub everything, leaving no markup at all.  This is compatible with the expectations
for Tags.

=head1 Functions

=head2 new

Missing POD for new.

=cut
