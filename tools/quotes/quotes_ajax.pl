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
use C4::Context;

my $cgi = CGI->new;
my $dbh = C4::Context->dbh;
my $sort_columns = ["id", "source", "text", "timestamp"];

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

# NOTE: This is a collection of ajax functions for use with tools/quotes.pl

my $params = $cgi->Vars; # NOTE: Multivalue parameters NOT allowed!!

print $cgi->header('application/json; charset=utf-8');

my $action = $params->{'action'} || 'get';
if ($action eq 'add') {
    my $sth = $dbh->prepare('INSERT INTO quotes (source, text) VALUES (?, ?);');
    $sth->execute($params->{'source'}, $params->{'text'});
    if ($sth->err) {
        warn sprintf('Database returned the following error: %s', $sth->errstr);
        exit 1;
    }
    my $new_quote_id = $dbh->{q{mysql_insertid}}; # ALERT: mysqlism here
    $sth = $dbh->prepare('SELECT * FROM quotes WHERE id = ?;');
    $sth->execute($new_quote_id);
    print to_json($sth->fetchall_arrayref, {utf8 =>1});
    exit 0;
}
elsif ($action eq 'edit') {
    my $aaData = [];
    my $editable_columns = [qw(source text)]; # pay attention to element order; these columns match the quotes table columns
    my $sth = $dbh->prepare("UPDATE quotes SET $editable_columns->[$params->{'column'}-1]  = ? WHERE id = ?;");
    $sth->execute($params->{'value'}, $params->{'id'});
    if ($sth->err) {
        warn sprintf('Database returned the following error: %s', $sth->errstr);
        exit 1;
    }
    $sth = $dbh->prepare("SELECT $editable_columns->[$params->{'column'}-1] FROM quotes WHERE id = ?;");
    $sth->execute($params->{'id'});
    $aaData = $sth->fetchrow_array();
    print Encode::encode('utf8', $aaData);

    exit 0;
}
elsif ($action eq 'delete') {
    my $sth = $dbh->prepare("DELETE FROM quotes WHERE id = ?;");
    $sth->execute($params->{'id'});
    if ($sth->err) {
        warn sprintf('Database returned the following error: %s', $sth->errstr);
        exit 1;
    }
    exit 0;
}
else {
    my $aaData = [];
    my $iTotalRecords = '';
    my $sth = '';

    $iTotalRecords = $dbh->selectrow_array('SELECT count(*) FROM quotes;');
    $sth = $dbh->prepare("SELECT * FROM quotes;");

    $sth->execute();
    if ($sth->err) {
        warn sprintf('Database returned the following error: %s', $sth->errstr);
        exit 1;
    }

    $aaData = $sth->fetchall_arrayref;
    my $iTotalDisplayRecords = $iTotalRecords; # no filtering happening here


    print to_json({
                    iTotalRecords       =>  $iTotalRecords,
                    iTotalDisplayRecords=>  $iTotalDisplayRecords,
                    sEcho               =>  $params->{'sEcho'},
                    aaData              =>  $aaData,
                  }, {utf8 =>1});
}
