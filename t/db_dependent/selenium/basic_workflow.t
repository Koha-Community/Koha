#!/usr/bin/perl

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



# wget https://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.1.jar # Does not work with 3.4, did not test the ones between
# sudo apt-get install xvfb firefox-esr
# SELENIUM_PATH=/home/vagrant/selenium-server-standalone-2.53.1.jar
# Xvfb :1 -screen 0 1024x768x24 2>&1 >/dev/null &
# DISPLAY=:1 java -jar $SELENIUM_PATH
#
# Then you can execute the test file.
#
# If you get:
# Wide character in print at /usr/local/share/perl/5.20.2/Test2/Formatter/TAP.pm line 105.
# #                   'Koha › Patrons › Add patron test_patron_surname (Adult)'
# #     doesn't match '(?^u:Patron details for test_patron_surname)'
#
# Ignore and retry (FIXME LATER...)

use Modern::Perl;

use Time::HiRes qw(gettimeofday);
use POSIX qw(strftime);
use C4::Context;
use C4::Biblio qw( AddBiblio );

use Koha::CirculationRules;

use Test::More tests => 22;
use MARC::Record;
use MARC::Field;

use t::lib::Selenium;

my $dbh      = C4::Context->dbh;

my $number_of_biblios_to_insert = 3;
our $sample_data = {
    category => {
        categorycode    => 'TEST_CAT',
        description     => 'test cat description',
        enrolmentperiod => '12',
        category_type   => 'A'
    },
    patron => {
        surname    => 'test_patron_surname',
        cardnumber => '4242424242',
        userid     => 'test_username',
        password   => '1BetterPassword',
        password2  => '1BetterPassword'
    },
    itemtype => {
        itemtype     => 'IT4TEST',
        description  => 'Just an itemtype for tests',
        rentalcharge => 0,
        notforloan   => 0,
    },
    issuingrule => {
        categorycode  => 'test_cat',
        itemtype      => 'IT4test',
        branchcode    => undef,
        maxissueqty   => '5',
        issuelength   => '5',
        lengthunit    => 'days',
        renewalperiod => '5',
        reservesallowed => '5',
        onshelfholds  => '1',
        opacitemholds => 'Y',
      },
};
our ( $borrowernumber, $start, $prev_time, $cleanup_needed );

SKIP: {
    eval { require Selenium::Remote::Driver; };
    skip "Selenium::Remote::Driver is needed for selenium tests.", 22 if $@;

    $cleanup_needed = 1;

    $dbh->do(q|INSERT INTO itemtypes(itemtype) VALUES (?)|, undef, $sample_data->{itemtype}{itemtype});

    open my $fh, '>>', '/tmp/output.txt';

    my $s = t::lib::Selenium->new;

    my $driver = $s->driver;
    my $base_url = $s->base_url;

    $start = gettimeofday;
    $prev_time = $start;
    $driver->get($base_url."mainpage.pl");
    like( $driver->get_title(), qr(Log in to Koha), );
    $s->auth;
    time_diff("main");

    $driver->get($base_url.'admin/categories.pl');
    like( $driver->get_title(), qr(Patron categories), );
    $driver->find_element('//a[@id="newcategory"]')->click;
    like( $driver->get_title(), qr(New category), );
    $s->fill_form( $sample_data->{category} );
    $driver->find_element('//fieldset[@class="action"]/input[@type="submit"]')->click;

    time_diff("add patron category");
    $driver->get($base_url.'/members/memberentry.pl?op=add&amp;categorycode='.$sample_data->{category}{categorycode});
    like( $driver->get_title(), qr(Add .*$sample_data->{category}{description}), );
    $s->fill_form( $sample_data->{patron} );
    $driver->find_element('//button[@id="saverecord"]')->click;
    like( $driver->get_title(), qr(Patron details for $sample_data->{patron}{surname}), );

    ####$driver->get($base_url.'/members/members-home.pl');
    ####fill_form( $driver, { searchmember => $sample_data->{patron}{cardnumber} } );
    ####$driver->find_element('//div[@id="header_search"]/div/form/input[@type="submit"]')->click;
    ####like( $driver->get_title(), qr(Patron details for), );

    time_diff("add patron");

    $borrowernumber = $dbh->selectcol_arrayref(q|SELECT borrowernumber FROM borrowers WHERE userid=?|, {}, $sample_data->{patron}{userid} )->[0];

    my @biblionumbers;
    for my $i ( 1 .. $number_of_biblios_to_insert ) {
        my $biblio = MARC::Record->new();
        my $title = 'test biblio '.$i;
        if ( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
            $biblio->append_fields(
                MARC::Field->new('200', ' ', ' ', a => 'test biblio '.$i),
                MARC::Field->new('200', ' ', ' ', f => 'test author '.$i),
            );
        } else {
            $biblio->append_fields(
                MARC::Field->new('245', ' ', ' ', a => 'test biblio '.$i),
                MARC::Field->new('100', ' ', ' ', a => 'test author '.$i),
            );
        }
        my ($biblionumber, $biblioitemnumber) = AddBiblio($biblio, '');
        push @biblionumbers, $biblionumber;
    }

    time_diff("add biblio");

    my $itemtype = $sample_data->{itemtype};

    my $issuing_rules = $sample_data->{issuingrule};
    Koha::CirculationRules->set_rules(
        {
            categorycode => $issuing_rules->{categorycode},
            itemtype     => $issuing_rules->{itemtype},
            branchcode   => $issuing_rules->{branchcode},
            rules => {
                maxissueqty     => $issuing_rules->{maxissueqty},
                issuelength     => $issuing_rules->{issuelength},
                lengthunit      => $issuing_rules->{lengthunit},
                renewalperiod   => $issuing_rules->{renewalperiod},
                reservesallowed => $issuing_rules->{reservesallowed},
                onshelfholds    => $issuing_rules->{onshelfholds},
                opacitemholds   => $issuing_rules->{opacitemholds},

              }
        }
    );


    for my $biblionumber ( @biblionumbers ) {
        $driver->get($base_url."/cataloguing/additem.pl?biblionumber=$biblionumber");
        like( $driver->get_title(), qr(test biblio \d+ by test author), );
        my $form = $driver->find_element('//form[@name="f"]');
        # select the text inputs that don't have display:none
        my $inputs = $driver->find_child_elements($form, '/.//*[not(self::node()[contains(@style,"display:none")])]/*[@type="text"]');
        for my $input ( @$inputs ) {
            my $id = $input->get_attribute('id');
            next unless $id =~ m|^tag_952_subfield|;

            my $effective_input = $input;
            my $v;

            # FIXME This is based on default values
            if (   $id =~ m|^tag_952_subfield_g|   # price
                or $id =~ m|^tag_952_subfield_v| ) # replacementprice
            {
                $v = '42';    # It's a price
            }
            elsif (
                $id =~ m|^tag_952_subfield_f| #tag_952_subfield_g
            ) {
                # It's a varchar(10)
                $v = 't_value_x';
            }
            elsif (
                $id =~ m|^tag_952_subfield_w| # replacementpricedate
            ) {
                $v = strftime("%Y-%m-%d", localtime);
                $effective_input = $driver->find_element('//div[@id="subfield952w"]/input[@type="text" and @class="input_marceditor items.replacementpricedate noEnterSubmit flatpickr-input"]');
            }
            elsif (
                $id =~ m|^tag_952_subfield_d| # dateaccessioned
            ) {
                next; # The input has been prefilled with %Y-%m-%d already
            }
            elsif (
                $id =~ m|^tag_952_subfield_3| # materials
            ) {
                $v = ""; # We don't want the checkin/checkout to need confirmation if CircConfirmItemParts is on
            }
            else {
                $v = 't_value_bib' . $biblionumber;
            }
            $effective_input->send_keys( $v );
        }

        $driver->find_element('//input[@name="add_submit"]')->click;
        like( $driver->get_title(), qr(Items.*Record #$biblionumber) );

        $dbh->do(q|UPDATE items SET notforloan=0 WHERE biblionumber=?|, {}, $biblionumber );
        $dbh->do(q|UPDATE biblioitems SET itemtype=? WHERE biblionumber=?|, {}, $itemtype->{itemtype}, $biblionumber);
        $dbh->do(q|UPDATE items SET itype=? WHERE biblionumber=?|, {}, $itemtype->{itemtype}, $biblionumber);
    }

    time_diff("add items");

    my $nb_of_checkouts = 0;
    for my $biblionumber ( @biblionumbers ) {
        $driver->get($base_url."/circ/circulation.pl?borrowernumber=".$borrowernumber);
        $driver->find_element('//input[@id="barcode"]')->send_keys('t_value_bib'.$biblionumber);
        $driver->find_element('//fieldset[@id="circ_circulation_issue"]/button[@type="submit"]')->click;
        $nb_of_checkouts++;
        like( $driver->get_title(), qr(Checking out to $sample_data->{patron}{surname}) );
        is( $driver->find_element('//a[@href="#checkouts"]')->get_attribute('text'), 'Checkouts ('.$nb_of_checkouts.')' );
    }

    time_diff("checkout");

    for my $biblionumber ( @biblionumbers ) {
        $driver->get($base_url."/circ/returns.pl");
        $driver->find_element('//input[@id="barcode"]')->send_keys('t_value_bib'.$biblionumber);
        $driver->find_element('//*[@id="circ_returns_checkin"]/div[2]/div[1]/div[2]/button')->click;
        like( $driver->get_title(), qr(Check in test biblio \d+) );
    }

    time_diff("checkin");

    #Place holds
    $driver->get($base_url."/reserve/request.pl?borrowernumber=$borrowernumber&biblionumber=".$biblionumbers[0]);
    $driver->find_element('//form[@id="hold-request-form"]//button[@type="submit"]')->click; # Biblio level
    $driver->pause(1000); # This seems wrong, since bug 19618 the hold is created async with an AJAX call. Not sure what is happening here but the next statements are exectuted before the hold is created and the count is wrong (still 0)
    my $patron = Koha::Patrons->find($borrowernumber);
    is( $patron->holds->count, 1, );

    $driver->get($base_url."/reserve/request.pl?borrowernumber=$borrowernumber&biblionumber=".$biblionumbers[1]);
    $driver->find_element('//form[@id="hold-request-form"]//input[@type="radio"]')->click; # Item level, there is only 1 item per bib so we are safe
    $driver->find_element('//form[@id="hold-request-form"]//button[@type="submit"]')->click;
    $driver->pause(1000);
    is( $patron->holds->count, 2, );

    time_diff("holds");

    close $fh;
    $driver->quit();
};

END {
    cleanup() if $cleanup_needed;
};

sub cleanup {
    my $dbh = C4::Context->dbh;
    $dbh->do(q|DELETE FROM issues where borrowernumber=?|, {}, $borrowernumber);
    $dbh->do(q|DELETE FROM old_issues where borrowernumber=?|, {}, $borrowernumber);
    for my $i ( 1 .. $number_of_biblios_to_insert ) {
        $dbh->do(qq|DELETE items, biblio FROM biblio INNER JOIN items ON biblio.biblionumber = items.biblionumber WHERE biblio.title = "test biblio$i"|);
    };
    $dbh->do(q|DELETE FROM borrowers WHERE userid = ?|, {}, $sample_data->{patron}{userid});
    $dbh->do(q|DELETE FROM categories WHERE categorycode = ?|, {}, $sample_data->{category}{categorycode});
    for my $i ( 1 .. $number_of_biblios_to_insert ) {
        $dbh->do(qq|DELETE FROM biblio WHERE title = "test biblio $i"|);
    };
    $dbh->do(q|DELETE FROM itemtypes WHERE itemtype=?|, undef, $sample_data->{itemtype}{itemtype});
    $dbh->do(q|DELETE FROM circulation_rules WHERE categorycode=? AND itemtype=? AND branchcode=?|, undef, $sample_data->{issuingrule}{categorycode}, $sample_data->{issuingrule}{itemtype}, $sample_data->{issuingrule}{branchcode});
}

sub time_diff {
    my $lib = shift;
    my $now = gettimeofday;
    warn "CP $lib = " . sprintf("%.2f", $now - $prev_time ) . "\n";
    $prev_time = $now;
}
