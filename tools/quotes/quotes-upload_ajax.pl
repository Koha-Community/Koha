#!/usr/bin/perl

# Copyright 2012 Foundations Bible College Inc.
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

use strict;
use warnings;

use CGI;
use JSON;
use autouse 'Data::Dumper' => qw(Dumper);

use C4::Auth;
use C4::Koha;
use C4::Context;
use C4::Output;

my $cgi = new CGI;
my $dbh = C4::Context->dbh;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'edit_quotes' },
        debug           => 1,
    }
);

my $success = 'true';

my $quotes = decode_json($cgi->param('quote'));
my $action = $cgi->param('action');

my $sth = $dbh->prepare('INSERT INTO quotes (source, text) VALUES (?, ?);');

my $insert_count = 0;

foreach my $quote (@$quotes) {
    $insert_count++ if $sth->execute($quote->[1], $quote->[2]);
    if ($sth->err) {
        warn sprintf('Database returned the following error: %s', $sth->errstr);
        $success = 'false';
    }
}

print $cgi->header('application/json');

print to_json({
                success => $success,
                records => $insert_count,
});
