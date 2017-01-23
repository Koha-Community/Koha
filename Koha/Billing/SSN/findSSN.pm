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
use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use HTTP::Cookies;

sub findSSN {
  # Get ssn for ssnkey using findssn web-service.

  # Allow key to either start with 'sotu' or not (the search is always
  # done with 'sotu' in the beginning because that's how findssn rolls).
  my $ssnkey=shift;
     $ssnkey=~s/^sotu//;
     $ssnkey='sotu' . $ssnkey;

  my ($url,
      $user,
      $password)=getfindssnconfig();

  my $useragent=LWP::UserAgent->new;
     $useragent->ssl_opts(verify_hostname=>0, SSL_verify_mode=> 0x00); # FIX-ME!

  my $jar=$useragent->cookie_jar(HTTP::Cookies->new());

  # Login
  my $request=POST($url . '/ssn/findssn', [username=>$user, password=>$password]);
  my $response=$useragent->request($request);

  # Get ssn
  $request=POST($url . '/ssn/findssn', [key=>$ssnkey]);
  $response=$useragent->request($request);

  # Findssn returns HTML-document, parse it and return ssn
  my @ssn=grep /<div>sotu[0-9]* *<br\/> */, split '\n', $response->content;
  if (defined $ssn[0]) {
    $ssn[0]=~s/^.*<br\/> *//; $ssn[0]=~s/<\/div>$//;
    undef $ssn[0] if $ssn[0] eq '';
  }
  return $ssn[0];
}

1;
