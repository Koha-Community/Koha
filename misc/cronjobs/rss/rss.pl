#!/usr/bin/perl

# This script can be used to generate rss 0.91 files for syndication.

# it should be run from cron like:
#
#    rss.pl config.conf
#

# Copyright 2003 Katipo Communications
# Copyright 2014 ByWater Solutions
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

use Modern::Perl;

use Template;
use C4::Context;
use Time::Local;
use POSIX;

my $dbh     = C4::Context->dbh;
my $file    = $ARGV[0];
my %config  = getConf("config");
my $outFile = $config{"output"};
my $feed    = Template->new();

my %channel = getConf("channel");
my %image   = getConf("image");
my $vars    = {
    OPACBaseURL      => C4::Context->preference('OPACBaseURL'),
    CHANNELTITLE     => $channel{'title'},
    CHANNELLINK      => $channel{'link'},
    CHANNELDESC      => $channel{'desc'},
    CHANNELLANG      => $channel{'lang'},
    CHANNELLASTBUILD => getDate(),

    IMAGETITLE       => $image{'title'},
    IMAGEURL         => $image{'url'},
    IMAGELINK        => $image{'link'},
    IMAGEDESCRIPTION => $image{'description'},
    IMAGEWIDTH       => $image{'width'},
    IMAGEHEIGHT      => $image{'height'},

    ITEMS => getItems( $config{'query'} )
};

my $template_path = $config{"template"};
open( my $fh, "<", $template_path ) or die "cannot open $template_path : $!";
$feed->process( $fh, $vars, $outFile );

sub getDate {
    my $date = strftime( "%a, %d %b %Y %T %Z", localtime );
    return $date;
}

sub getConf {
    my $section = shift;
    my %return;
    my $inSection = 0;

    open( FILE, $file ) or die "can't open $file";
    while (<FILE>) {
        if ($inSection) {
            my @line = split( /=/, $_, 2 );
            unless ( $line[1] ) {
                $inSection = 0;
            }
            else {
                my ( $key, $value ) = @line;
                chomp $value;
                $return{$key} = $value;
            }
        }
        else {
            if ( $_ eq "$section\n" ) { $inSection = 1 }
        }
    }
    close FILE;
    return %return;
}

sub getItems {
    my $query = shift;
    $query .= " limit 15";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my @return;
    while ( my $data = $sth->fetchrow_hashref ) {
        foreach my $key ( keys %$data ) {
            my $value = $data->{$key};
            $value = '' unless defined $value;
            $value =~ s/\&/\&amp;/g and $data->{$key} = $value;
        }
        push @return, $data;
    }
    $sth->finish;
    return \@return;
}
