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
        template_name   => "opac-browser.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
        debug           => 1,
    }
);

# the level of browser to display
my $level = $query->param('level') || 0;
my $filter = $query->param('filter');
$level++; # the level passed is the level of the PREVIOUS list, not the current one. Thus the ++

# build this level loop
my $sth = $dbh->prepare("SELECT * FROM browser WHERE level=? and classification like ? ORDER BY classification");
$sth->execute($level,$filter."%");
my @level_loop;
my $i=0;
while (my $line = $sth->fetchrow_hashref) {
    $line->{description} =~ s/\((.*)\)//g;
    $i++;
    $line->{count3}=1 unless $i %3;
    push @level_loop,$line;
}

# now rebuild hierarchy loop
$sth = $dbh->prepare("SELECT * FROM browser where classification=?");
$filter =~ s/\.//g;
my @hierarchy_loop;
for (my $i=1;$i <=length($filter);$i++) {
    $sth->execute(substr($filter,0,$i));
    my $line = $sth->fetchrow_hashref;
    push @hierarchy_loop,$line;
}

$template->param(
    LEVEL_LOOP => \@level_loop,
    HIERARCHY_LOOP => \@hierarchy_loop,
);

output_html_with_http_headers $query, $cookie, $template->output;
