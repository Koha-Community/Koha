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

use Modern::Perl;
use utf8;

use C4::Context;

use Test::More;
use Test::MockModule;

use C4::Context;
use C4::Biblio qw( AddBiblio );
use C4::Circulation qw( AddIssue );
use Koha::AuthUtils;
use t::lib::Mocks;
use t::lib::Selenium;
use t::lib::TestBuilder;
use t::lib::Mocks;

eval { require Selenium::Remote::Driver; };
if ( $@ ) {
    plan skip_all => "Selenium::Remote::Driver is needed for selenium tests.";
} else {
    plan tests => 8;
}

my $s = t::lib::Selenium->new;

my $driver = $s->driver;
my $opac_base_url = $s->opac_base_url;
my $base_url = $s->base_url;
my $builder = t::lib::TestBuilder->new;

# It seems that we do not have enough records indexed with ES
my $SearchEngine_value = C4::Context->preference('SearchEngine');
C4::Context->set_preference('SearchEngine', 'Zebra');

my $AudioAlerts_value = C4::Context->preference('AudioAlerts');
C4::Context->set_preference('AudioAlerts', '1');

our @cleanup;
subtest 'OPAC - borrowernumber, branchcode and categorycode as html attributes' => sub {
    plan tests => 3;

    my $patron = $builder->build_object(
        { class => 'Koha::Patrons', value => { flags => 1 } } );
    my $password = Koha::AuthUtils::generate_password($patron->category);
    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
    $patron->set_password({ password => $password });
    $s->opac_auth( $patron->userid, $password );
    my $elt = $driver->find_element('//span[@class="loggedinusername"]');
    is( $elt->get_attribute('data-branchcode', 1), $patron->library->branchcode,
        "Since bug 20921 span.loggedinusername should contain data-branchcode"
        # No idea why we need the second param of get_attribute(). As
        # data-branchcode is still there after page finished loading.
    );
    is( $elt->get_attribute('data-borrowernumber', 1), $patron->borrowernumber,
"Since bug 20921 span.loggedinusername should contain data-borrowernumber"
    );
    is( $elt->get_attribute('data-categorycode', 1), $patron->categorycode,
"Since bug 26847 span.loggedinusername should contain data-categorycode"
    );
    push @cleanup, $patron, $patron->category, $patron->library;
};

subtest 'OPAC - Bibliographic record detail page must contain the data-biblionumber' => sub {
    plan tests => 1;

    my $builder = t::lib::TestBuilder->new;

    my ( $biblionumber, $biblioitemnumber ) = add_biblio();
    my $biblio = Koha::Biblios->find($biblionumber);

    $driver->get( $opac_base_url . "opac-detail.pl?biblionumber=$biblionumber" );

    my $elt = $driver->find_element('//div[@id="catalogue_detail_biblio"]');
    is( $elt->get_attribute( 'data-biblionumber', 1 ),
        $biblionumber, "#catalogue_detail_biblio contains data-biblionumber" );

    push @cleanup, $biblio;
};

subtest 'Bibliographic record detail page must not explode even with invalid metadata' => sub {
    plan tests => 2;

    my $builder = t::lib::TestBuilder->new;
    my $patron = $builder->build_object({ class => 'Koha::Patrons', value => { flags => 0 }});

    my $mainpage = $s->base_url . q|mainpage.pl|;
    $driver->get($mainpage . q|?logout.x=1|);
    like( $driver->get_title(), qr(Log in to Koha), );
    $s->auth;

    my ( $biblionumber, $biblioitemnumber ) = add_biblio();
    my $biblio = Koha::Biblios->find($biblionumber);

    # Note that there are several "non xml chars" in the control fields
    my $invalid_data = qq{<?xml version="1.0" encoding="UTF-8"?>
    <record
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
        xmlns="http://www.loc.gov/MARC21/slim">
    <leader>00772nam0a2200277   4500</leader>
    <controlfield tag="001">00aD000015937</controlfield>
    <controlfield tag="004">00satmrnu0</controlfield>
    <controlfield tag="008">00ar19881981bdkldan</controlfield>
    </record>};
    $biblio->metadata->metadata($invalid_data)->store();

    $driver->get( $base_url . "/catalogue/detail.pl?biblionumber=$biblionumber" );

    my $biberror = $driver->find_element('//span[@class="biberror"]')->get_text();
    is( $biberror, "There is an error with this bibliographic record, the view may be degraded.");
    push @cleanup, $biblio;
};

subtest 'Play sound on the circulation page' => sub {
    plan tests => 1;

    my $builder  = t::lib::TestBuilder->new;
    my $patron = $builder->build_object({ class => 'Koha::Patrons', value => { flags => 0 }});

    my $mainpage = $s->base_url . q|mainpage.pl|;
    $driver->get($mainpage . q|?logout.x=1|);
    like( $driver->get_title(), qr(Log in to Koha), );
    $s->auth;

    $driver->get( $base_url . "/circ/circulation.pl?borrowernumber=" . $patron->borrowernumber );

    my $audio_node = $driver->find_element('//span[@id="audio-alert"]/audio[@src="/intranet-tmpl/prog/sound/beep.ogg"]');

    push @cleanup, $patron, $patron->category, $patron->library;
};

subtest 'Display circulation table correctly' => sub {
    plan tests => 1;

    my $builder = t::lib::TestBuilder->new;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode, flags => 0 }
        }
    );

    my ( $biblionumber, $biblioitemnumber ) = add_biblio();
    my $item_type = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $item = $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            library      => $library->branchcode,
            itype        => $item_type->itemtype,
        }
    );
    my $context = Test::MockModule->new('C4::Context');
    $context->mock(
        'userenv',
        sub {
            return { branch => $library->branchcode };
        }
    );

    C4::Circulation::AddIssue( $patron->unblessed, $item->barcode );

    my $mainpage = $s->base_url . q|mainpage.pl|;
    $driver->get($mainpage . q|?logout.x=1|);
    $s->auth;

    $driver->get( $base_url
          . "/circ/circulation.pl?borrowernumber="
          . $patron->borrowernumber );

    # Display the table clicking on the "Show checkouts" button
    $driver->find_element('//a[@id="issues-table-load-now-button"]')->click;

    my @thead_th = $driver->find_elements('//table[@id="issues-table"]/thead/tr/th');
    my $thead_length = 0;
    $thead_length += $_->get_attribute('colspan', 1) || 0 for @thead_th;

    my @tfoot_td = $driver->find_elements('//table[@id="issues-table"]/tfoot/tr/td');
    my $tfoot_length = 0;
    $tfoot_length += $_->get_attribute('colspan', 1) || 0 for @tfoot_td;

    my @tbody_td = $driver->find_elements('//table[@id="issues-table"]/tbody/tr[2]/td');
    my $tbody_length = 0;
    $tbody_length += 1 for @tbody_td;

    is( $thead_length == $tfoot_length && $tfoot_length == $tbody_length,
        1, "Checkouts table must be correctly aligned" )
      or diag(
        "thead: $thead_length ; tfoot: $tfoot_length ; tbody: $tbody_length");

    push @cleanup, $patron->checkouts, $item, $item->biblio, $patron,
      $patron->category, $library;
};

subtest 'XSS vulnerabilities in pagination' => sub {
    plan tests => 3;

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    for ( 1 .. 30 ) { # We want the pagination to be displayed
        push @cleanup, $builder->build_object(
            {
                class => 'Koha::Virtualshelves',
                value => {
                    public                   => 1,
                    allow_change_from_owner  => 1,
                    allow_change_from_others => 0,
                    owner                    => $patron->borrowernumber
                }
            }
        );
    }

    my $password = Koha::AuthUtils::generate_password($patron->category);
    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
    $patron->set_password({ password => $password });
    $s->opac_auth( $patron->userid, $password );

    my $public_lists = $s->opac_base_url . q|opac-shelves.pl?op=list&public=1|;
    $driver->get($public_lists);

    $s->remove_error_handler;
    my $alert_text = eval { $driver->get_alert_text() };
    $s->add_error_handler;
    is( $alert_text, undef, 'No alert box displayed' );

    my $booh_alert = 'booh!';
    $public_lists = $s->opac_base_url . qq|opac-shelves.pl?op=list&public=1"><script>alert('$booh_alert')</script>|;
    $driver->get($public_lists);

    $s->remove_error_handler;
    $alert_text = eval { $driver->get_alert_text() };
    $s->add_error_handler;
    is( $alert_text, undef, 'No alert box displayed, even if evil intent' );

    my $second_page = $driver->find_element('//div[@class="pages"]/span[@class="currentPage"]/following-sibling::a');
    like( $second_page->get_attribute('href'), qr{(?|&)public=1(&|$)}, 'The second page should display category without the invalid value' );

    push @cleanup, $patron, $patron->category, $patron->library;

};

subtest 'Encoding in session variables' => sub {
    plan tests => 18;

    my $builder = t::lib::TestBuilder->new;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode, flags => 0 }
        }
    );

    my $biblio = $builder->build_sample_biblio;
    my $item = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library->branchcode,
        }
    );

    my $original_SessionStorage = C4::Context->preference('SessionStorage');
    for my $SessionStorage ( qw( memcached mysql tmp ) ) {
        C4::Context->set_preference( 'SessionStorage', $SessionStorage );
        for my $branchname (qw( Test1 Test2❤️ Test3ä )) {
            my $library =
              Koha::Libraries->find($branchname) || $builder->build_object(
                {
                    class => 'Koha::Libraries',
                    value => {
                        branchcode => $branchname,
                        branchname => $branchname,
                    }
                }
              );
            # Make sure we are logged in
            $driver->get( $base_url . q|mainpage.pl?logout.x=1| );
            $s->auth;
            # Switch to the new library
            $driver->get( $base_url . 'circ/set-library.pl' );
            $s->fill_form( { branch => $branchname } );
            $s->submit_form;
            # Check an item out
            $driver->get( $base_url
                  . 'circ/circulation.pl?borrowernumber='
                  . $patron->borrowernumber );
            # We must have the logged-in-branch-name displayed, or we got a 500
            is(
                $driver->find_element( '//span[@class="logged-in-branch-name"]')->get_text(),
                $branchname,
                sprintf( "logged-in-branch-name set - SessionStorage=%s, branchname=%s", $SessionStorage, $branchname
                )
            );

            $driver->find_element('//input[@id="barcode"]')->send_keys( $item->barcode );
            $driver->find_element('//fieldset[@id="circ_circulation_issue"]/button[@type="submit"]')->click;

            # Display the table clicking on the "Show checkouts" button
            $driver->find_element('//a[@id="issues-table-load-now-button"]')
              ->click;

            my @tds = $driver->find_elements(
                '//table[@id="issues-table"]/tbody/tr[2]/td');

            # Select the td for "Checked out from" (FIXME this is not robust and could be improved
            my $td_checked_out_from = $tds[8];
            is(
                $td_checked_out_from->get_text(),
                $branchname,
                sprintf( "'Checked out from' column should contain the branchname - SessionStorage=%s, branchname=%s", $SessionStorage, $branchname )
            );

            # Remove the check in
            Koha::Checkouts->find({ itemnumber => $item->itemnumber })->delete;
        }
    }

    C4::Context->set_preference('SessionStorage', $original_SessionStorage);
    push @cleanup, $item, $biblio, $patron, $patron->category, $patron->library;
    push @cleanup, Koha::Libraries->find($_) for qw( Test1 Test2❤️ Test3ä );

};

subtest 'OPAC - Suggest for purchase' => sub {
    plan tests => 4;

    my $builder = t::lib::TestBuilder->new;

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
    my $password = Koha::AuthUtils::generate_password( $patron->category );
    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
    $patron->set_password( { password => $password } );
    $s->opac_auth( $patron->userid, $password );

    my ( $biblionumber, $biblioitemnumber ) = add_biblio();
    my $biblio = Koha::Biblios->find($biblionumber);
    $driver->get( $opac_base_url . "opac-detail.pl?biblionumber=$biblionumber" );

    $s->click({ href => '/opac-suggestions.pl?op=add&biblionumber=' . $biblionumber });
    is( $driver->find_element('//a[@id="title"]')->get_text(),
        $biblio->title,
        "Suggestion's title correctly filled in with biblio's title" );

    $driver->find_element('//textarea[@id="note"]')->send_keys('some notes');
    $s->submit_form;

    my $suggestions = Koha::Suggestions->search( { biblionumber => $biblio->biblionumber } );
    is( $suggestions->count, 1, 'Suggestion created' );
    my $suggestion = $suggestions->next;
    is( $suggestion->title, $biblio->title, q{suggestion's title has biblio's title} );
    is( $suggestion->note, 'some notes', q{suggestion's note correctly saved} );

    push @cleanup, $biblio, $suggestion;
};


$driver->quit();

END {
    C4::Context->set_preference('SearchEngine', $SearchEngine_value);
    C4::Context->set_preference('AudioAlerts', $AudioAlerts_value);
    $_->delete for @cleanup;
};

sub add_biblio {
    my ($title, $author) = @_;

    my $marcflavour = C4::Context->preference('marcflavour');

    my $biblio = MARC::Record->new();
    my ( $tag, $code );
    $tag = $marcflavour eq 'UNIMARC' ? '200' : '245';
    $biblio->append_fields(
        MARC::Field->new($tag, ' ', ' ', a => $title || 'a title'),
    );

    ($tag, $code) = $marcflavour eq 'UNIMARC' ? (200, 'f') : (100, 'a');
    $biblio->append_fields(
        MARC::Field->new($tag, ' ', ' ', $code => $author || 'an author'),
    );

    return C4::Biblio::AddBiblio($biblio, '');
}
