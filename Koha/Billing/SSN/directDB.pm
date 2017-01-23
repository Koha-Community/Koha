#!/usr/bin/perl
# Outi Billing Version 170201 - Written by Pasi Korkalo
# Copyright (C)2016-2017 Koha-Suomi Oy
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use utf8;
use DBI;
use strict;
use warnings;

sub directDB {
  my ($host, $port, $user, $password)=getssndbconfig();
  my $dbh_ssn=DBI->connect('DBI:mysql:database=ssn:host=' . $host .':port=' . $port, $user, $password);
  my $sth_ssn=$dbh_ssn->prepare('SELECT ssnvalue
                                 FROM ssn
                                 WHERE ssnkey=?;');

  my $ssnkey=shift;
     $ssnkey=~s/^sotu//;

  $sth_ssn->execute($ssnkey);
  return $sth_ssn->fetchrow_array();
}

1;
