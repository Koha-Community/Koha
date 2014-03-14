#!/usr/bin/perl

# Copyright 2011-2013 Biblibre SARL
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
use CGI qw ( -utf8 );
use C4::Context;
use C4::Serials::Numberpattern;
use C4::Auth qw/check_cookie_auth/;
use URI::Escape;

my $input = new CGI;

my ($auth_status, $sessionID) = check_cookie_auth($input->cookie('CGISESSID'), { serials => '*' });
if ($auth_status ne "ok") {
    print $input->header(-type => 'text/plain', -status => '403 Forbidden');
    exit 0;
}

my $numberpattern;
foreach (qw/ numberingmethod label1 label2 label3 add1 add2 add3
  every1 every2 every3 setto1 setto2 setto3 whenmorethan1 whenmorethan2
  whenmorethan3 numbering1 numbering2 numbering3 locale /) {
    $numberpattern->{$_} = $input->param($_);
}
# patternname is label in database
$numberpattern->{'label'} = $input->param('patternname');

# Check if pattern already exist in database
my $dbh = C4::Context->dbh;
my $query = qq{
    SELECT id
    FROM subscription_numberpatterns
    WHERE STRCMP(label, ?) = 0
};
my $sth = $dbh->prepare($query);
my $rv = $sth->execute($numberpattern->{'label'});
my $numberpatternid;
if($rv == 0) {
    # Pattern does not exists
    $numberpatternid = AddSubscriptionNumberpattern($numberpattern);
} else {
    ($numberpatternid) = $sth->fetchrow_array;
    $numberpattern->{'id'} = $numberpatternid;
    ModSubscriptionNumberpattern($numberpattern);
}

binmode STDOUT, ":encoding(UTF-8)";
print $input->header(-type => 'text/plain', -charset => 'UTF-8');
print "{\"numberpatternid\":\"$numberpatternid\"}";
