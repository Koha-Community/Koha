package Koha::Util::FrameworkPlugin;

# Module contains subroutines used in the framework plugins
#
# Copyright 2014 Koha Development Team
#
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
#

use Modern::Perl;

our ( @ISA, @EXPORT, @EXPORT_OK );
BEGIN {
    require Exporter;
    @ISA = qw( Exporter );
    @EXPORT = qw( );
    @EXPORT_OK = qw( wrapper date_entered );
}

=head1 NAME

Koha::Util::FrameworkPlugin - utility class with routines for framework plugins

=head1 FUNCTIONS

=head2 wrapper

    wrapper returns a text for strings containing spaces, pipe chars, ...
    The wrapper subroutine is used in several UNIMARC plugins.

=cut

sub wrapper {
    my ( $str ) = @_;
    return "space" if $str eq " ";
    return "dblspace" if $str eq "  ";
    return "pipe" if $str eq "|";
    return "dblpipe" if $str eq "||";
    return $str;
}

=head2 date_entered

    date_entered returns date in yymmdd format as needed by MARC21 field 008

=cut

sub date_entered {
    # find today's date
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year +=1900;
    $mon +=1;
    return substr($year,2,2).sprintf ("%0.2d", $mon).sprintf ("%0.2d",$mday);
}

1;
