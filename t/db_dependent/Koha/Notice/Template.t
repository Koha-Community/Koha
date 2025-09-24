#!/usr/bin/perl

# Copyright 2024 Koha Development team
#
# This file is part of Koha
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
# along with Koha; if not, see <https://www.gnu.org/licenses>

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;

use_ok('Koha::Notice::Template');

subtest 'get_default() tests' => sub {
    plan tests => 1;

    my $module = 'circulation';
    my $code   = 'CHECKINSLIP';
    my $mtt    = 'print';
    my $lang   = 'en';

    my $template = Koha::Notice::Template->new(
        {
            module                 => $module,
            code                   => $code,
            message_transport_type => $mtt,
            lang                   => $lang
        }
    );

    my $sample = $template->get_default;

    # Expected content
    my $expected_sample = '<h3>[% branch.branchname %]</h3>
Checked in items for [% borrower.title %] [% borrower.firstname %] [% borrower.initials %] [% borrower.surname %] <br>
([% borrower.cardnumber %]) <br>
<br>
[% today | $KohaDates %]<br>
<br>
<h4>Checked in today</h4>
[% FOREACH checkin IN old_checkouts %]
[% SET item = checkin.item %]
<p>
[% item.biblio.title %] <br>
Barcode: [% item.barcode %] <br>
</p>
[% END %]';
    $expected_sample =~ s/\n/\r\n/g;

    is( $sample, $expected_sample, "Content retrieved correctly" );
};

1;
