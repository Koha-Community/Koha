#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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


=head1 opac-tags_subject.pl

TODO :: Description here

=cut

use strict;
use C4::Auth;
use C4::Context;
use C4::Output;
use CGI;
use C4::Biblio;
use C4::Koha;       # use getitemtypeinfo

my $query = new CGI;

my $dbh = C4::Context->dbh;

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-tags_subject.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
        debug           => 1,
    }
);

my $number = $query->param('number') || 100;

my $sth = $dbh->prepare("SELECT entry,weight FROM tags ORDER BY weight DESC LIMIT $number");
$sth->execute;

my %result;
my $max=0;
my $min=9999;
my ($entry,$weight);
while (($entry,$weight) = $sth->fetchrow) {
    $result{$entry}=$weight;
    $max = $weight if $weight > $max;
    $min = $weight if $weight < $min;
}

$min++ if $min == $max;

my @loop;
foreach my $entry (sort keys %result) {
    my %line;
    $line{entry} = $entry;
    $line{weight} = int(($result{$entry}-$min)/($max-$min)*25)+10;
    push @loop, \%line;
}
$template->param(
    LOOP => \@loop,
    number => $number
);

output_html_with_http_headers $query, $cookie, $template->output;
