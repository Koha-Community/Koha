#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2017  Catalyst IT
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

#This selenium test is to test authentication, by performing the following: create a category and patron (same as basic_workflow.t). Then the superlibrarian logs out and the created patron must log into the staff intranet and OPAC

#Note: If you are testing this on kohadevbox with selenium installed in kohadevbox then you need to set the staffClientBaseURL to localhost:8080 and the OPACBaseURL to localhost:80

use Modern::Perl;

use Time::HiRes qw(gettimeofday);
use C4::Context;
use C4::Biblio qw( AddBiblio ); # We shouldn't use it

use Test::More tests => 9;
use MARC::Record;
use MARC::Field;

my $dbh = C4::Context->dbh;
my $login = $ENV{KOHA_USER} || 'koha';
my $password = $ENV{KOHA_PASS} || 'koha';
my $staff_client_base_url =
    $ENV{KOHA_INTRANET_URL} || C4::Context->preference("staffClientBaseUrl") || q{};
my $base_url= $staff_client_base_url . "/cgi-bin/koha/";
my $opac_url = $ENV{KOHA_OPAC_URL} || C4::Context->preference("OPACBaseURL") || q{};


our $sample_data = {
    category => {
        categorycode    => 'test_cat',
        description     => 'test cat description',
        enrolmentperiod => '12',
        category_type   => 'A'
    },
    patron => {
        surname    => 'test_patron_surname',
        cardnumber => '4242424242',
        userid     => 'test_username',
        password   => 'Password123',
        password2  => 'Password123'
    },
};

my $patronusername="test_username";
my $patronpassword="password";

our ( $borrowernumber, $start, $prev_time, $cleanup_needed );

SKIP: {
    eval { require Selenium::Remote::Driver; };
    skip "Selenium::Remote::Driver is needed for selenium tests.", 20 if $@;

    $cleanup_needed = 1;

    open my $fh, '>>', '/tmp/output.txt';

    my $driver = Selenium::Remote::Driver->new;
    $start = gettimeofday;
    $prev_time = $start;
    $driver->get($base_url."mainpage.pl");
    like( $driver->get_title(), qr(Log in to Koha), );
    auth( $driver, $login, $password );
    time_diff("main");

    $driver->get($base_url.'admin/categories.pl');
    like( $driver->get_title(), qr(Patron categories), );
    $driver->find_element('//a[@id="newcategory"]')->click;
    like( $driver->get_title(), qr(New category), );
    fill_form( $driver, $sample_data->{category} );
    $driver->find_element('//fieldset[@class="action"]/input[@type="submit"]')->click;

    time_diff("add patron category");
    $driver->get($base_url.'/members/memberentry.pl?op=add&amp;categorycode='.$sample_data->{category}{categorycode});
    like( $driver->get_title(), qr(Add .*$sample_data->{category}{description}), );
    fill_form( $driver, $sample_data->{patron} );
    $driver->find_element('//button[@id="saverecord"]')->click;
    like( $driver->get_title(), qr(Patron details for $sample_data->{patron}{surname}), );
    time_diff("add patron");

    $driver->get($base_url.'/mainpage.pl?logout.x=1');
    like( $driver->get_title(), qr(Log in to Koha), );
    time_diff("Logout");

    $driver->get($base_url."mainpage.pl");
    like( $driver->get_title(), qr(Log in to Koha), );
    patron_auth( $driver, $sample_data->{patron} );
    time_diff("New patron logs into intranet");

    $driver->get($base_url.'/mainpage.pl?logout.x=1');
    like( $driver->get_title(), qr(Log in to Koha), );
    time_diff("Logout of new patron from staff intranet");

    $driver->get($opac_url);
    like( $driver->get_title(), qr(Koha online catalog), );
    patron_opac_auth( $driver, $sample_data->{patron} );
    time_diff("New patron logs into OPAC");

    close $fh;
    $driver->quit();
};

END {
    cleanup() if $cleanup_needed;
};

sub auth {
    my ( $driver, $login, $password) = @_;
    fill_form( $driver, { userid => $login, password => $password } );
    my $login_button = $driver->find_element('//input[@id="submit"]');
    $login_button->submit();
}

sub patron_auth {
    my ( $driver,$patronusername, $patronpassword) = @_;
    fill_form( $driver, { userid => $patronusername, password => $patronpassword } );
    my $login_button = $driver->find_element('//input[@id="submit"]');
    $login_button->submit();
}

sub patron_opac_auth {
    my ( $driver,$patronusername, $patronpassword) = @_;
    fill_form( $driver, { userid => $patronusername, password => $patronpassword } );
    my $login_button = $driver->find_element('//input[@value="Log in"]');
    $login_button->submit();
}

sub fill_form {
    my ( $driver, $values ) = @_;
    while ( my ( $id, $value ) = each %$values ) {
        my $element = $driver->find_element('//*[@id="'.$id.'"]');
        my $tag = $element->get_tag_name();
        if ( $tag eq 'input' ) {
            $driver->find_element('//input[@id="'.$id.'"]')->send_keys($value);
        } elsif ( $tag eq 'select' ) {
            $driver->find_element('//select[@id="'.$id.'"]/option[@value="'.$value.'"]')->click;
        }
    }
}

sub cleanup {
    my $dbh = C4::Context->dbh;
    $dbh->do(q|DELETE FROM categories WHERE categorycode = ?|, {}, $sample_data->{category}{categorycode});
    $dbh->do(q|DELETE FROM borrowers WHERE userid = ?|, {}, $sample_data->{patron}{userid});
}

sub time_diff {
    my $lib = shift;
    my $now = gettimeofday;
    warn "CP $lib = " . sprintf("%.2f", $now - $prev_time ) . "\n";
    $prev_time = $now;
}
