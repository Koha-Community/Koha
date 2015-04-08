#!/usr/bin/perl

# Copyright 2011 - Dobrica Pavlinusic
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

use warnings;
use strict;

use LWP::UserAgent;
use File::Slurp;

if ( $#ARGV >= 3 && ! caller ) { # process command-line params only if not called as module!
    my ( $url, $user, $password, $biblionumber, $file ) = @ARGV;

    my $svc = Koha::SVC->new(
        url      => $url,
        user     => $user,
        password => $password,
        debug    => $ENV{DEBUG},
    );

    if ( ! $file ) {
        my $marcxml = $svc->get( $biblionumber );
        my $file = "bib-$biblionumber.xml";
        write_file $file , $marcxml;
        print "saved $file ", -s $file, " bytes\n";
        print $marcxml;
    } else {
        print "update $biblionumber from $file\n";
        $svc->post( $biblionumber, scalar read_file($file) );
    }

    exit 0;
}

package Koha::SVC;
use warnings;
use strict;

=head1 NAME

Koha::SVC

=head1 DESCRIPTION

Call Koha's C</svc/> API to fetch/update records

This script can be used from other scripts as C<Koha::SVC> module or run
directly using syntax:

  koha-svc.pl http://koha-dev:8080/cgi-bin/koha/svc svc-user svc-password $biblionumber [bib-42.xml]

If called without last argument (MARCXML filename) it will fetch C<$biblionumber> from Koha and create
C<bib-$biblionumber.xml> file from it. When called with xml filename, it will update record in Koha.

This script is intentionally separate from Koha itself and dependencies which Koha has under
assumption that you might want to run it on another machine (or create custom script which mungles
Koha's records from other machine without bringing all Koha dependencies with it).

=head1 USAGE

This same script can be used as module (as it defines T<Koha::SVC> package) using

  require "koha-svc.pl"

at begining of script. Rest of API is described below. Example of it's usage is at beginning of this script.

=head2 new

  my $svc = Koha::SVC->new(
    url      => 'http://koha-dev:8080/cgi-bin/koha/svc',
    user     => 'svc-user',
    password => 'svc-password',
    debug    => 0,
  );

URL must point to Koha's B<intranet> address and port.

Specified user must have C<editcatalogue> permission.

=cut

sub new {
    my $class = shift;
    my $self = {@_};
    bless $self, $class;

    my $url = $self->{url} || die "no url found";
    my $user = $self->{user} || die "no user specified";
    my $password = $self->{password} || die "no password";

    my $ua = LWP::UserAgent->new();
    $ua->cookie_jar({});
    my $resp = $ua->post( "$url/authentication", {userid =>$user, password => $password} );
    die $resp->status_line unless $resp->is_success;

    warn "# $user $url = ", $resp->decoded_content, "\n" if $self->{debug};

    $self->{ua} = $ua;

    return $self;
}

=head2 get

  my $marcxml = $svc->get( $biblionumber );

=cut

sub get {
    my ($self,$biblionumber) = @_;

    my $url = $self->{url};
    warn "# get $url/bib/$biblionumber\n" if $self->{debug};
    my $resp = $self->{ua}->get( "$url/bib/$biblionumber" );
    die $resp->status_line unless $resp->is_success;
    return $resp->decoded_content;
}

=head2 post

  my $marcxml = $svc->post( $biblionumber, $marcxml );

=cut

sub post {
    my ($self,$biblionumber,$marcxml) = @_;
    my $url = $self->{url};
    warn "# post $url/bib/$biblionumber\n" if $self->{debug};
    my $resp = $self->{ua}->post( "$url/bib/$biblionumber", 'Content_type' => 'text/xml', Content => $marcxml );
    die $resp->status_line unless $resp->is_success;
    return $resp->decoded_content;
}

1;
