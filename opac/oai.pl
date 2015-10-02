#!/usr/bin/perl

# Copyright Tamil s.a.r.l. 2008-2015
# Copyright Biblibre 2008-2015
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.


use Modern::Perl;
use CGI qw( :standard -oldstyle_urls -utf8 );
use vars qw( $GZIP );
use C4::Context;
use Koha::OAI::Server::Repository;


BEGIN {
    eval { require PerlIO::gzip };
    $GZIP = ($@) ? 0 : 1;
}

unless ( C4::Context->preference('OAI-PMH') ) {
    print
        header(
            -type       => 'text/plain; charset=utf-8',
            -charset    => 'utf-8',
            -status     => '404 OAI-PMH service is disabled',
        ),
        "OAI-PMH service is disabled";
    exit;
}

my @encodings = http('HTTP_ACCEPT_ENCODING');
if ( $GZIP && grep { defined($_) && $_ eq 'gzip' } @encodings ) {
    print header(
        -type               => 'text/xml; charset=utf-8',
        -charset            => 'utf-8',
        -Content-Encoding   => 'gzip',
    );
    binmode( STDOUT, ":gzip" );
}
else {
    print header(
        -type       => 'text/xml; charset=utf-8',
        -charset    => 'utf-8',
    );
}

binmode STDOUT, ':encoding(UTF-8)';

my $repository = Koha::OAI::Server::Repository->new();
