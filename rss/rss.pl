#!/usr/bin/perl

# This script can be used to generate rss 0.91 files for syndication.

# it should be run from cron like:
#
#    rss.pl config.conf
#

# Copyright 2003 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use warnings;

use HTML::Template::Pro;
use C4::Context;
use Time::Local;
use POSIX;

my $dbh     = C4::Context->dbh;
my $file    = $ARGV[0];
my %config  = getConf("config");
my $outFile = $config{"output"};
my $feed    = HTML::Template::Pro->new( filename => $config{"tmpl"} );

my %channel = getConf("channel");
$feed->param( CHANNELTITLE     => $channel{'title'} );
$feed->param( CHANNELLINK      => $channel{'link'} );
$feed->param( CHANNELDESC      => $channel{'desc'} );
$feed->param( CHANNELLANG      => $channel{'lang'} );
$feed->param( CHANNELLASTBUILD => getDate() );

my %image = getConf("image");
$feed->param( IMAGETITLE       => $image{'title'} );
$feed->param( IMAGEURL         => $image{'url'} );
$feed->param( IMAGELINK        => $image{'link'} );
$feed->param( IMAGEDESCRIPTION => $image{'description'} );
$feed->param( IMAGEWIDTH       => $image{'width'} );
$feed->param( IMAGEHEIGHT      => $image{'height'} );

#
# handle the items
#
$feed->param( ITEMS => getItems( $config{'query'} ) );

open( FILE, ">$outFile" ) or die "can't open $outFile";
print FILE $feed->output();
close FILE;

sub getDate {

    #    my $date = localtime(timelocal(localtime));
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
            } else {
                my ( $key, $value ) = @line;
                chomp $value;
                $return{$key} = $value;
            }
        } else {
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
