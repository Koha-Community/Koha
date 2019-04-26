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

use C4::Context;

use Test::More tests => 5;
use Test::MockModule;

use C4::Context;
use C4::Biblio qw( AddBiblio );
use C4::Circulation;
use Koha::AuthUtils;
use t::lib::Selenium;
use t::lib::TestBuilder;
use t::lib::Mocks;

eval { require Selenium::Remote::Driver; };
skip "Selenium::Remote::Driver is needed for selenium tests.", 1 if $@;

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
subtest 'OPAC - borrowernumber and branchcode as html attributes' => sub {
    plan tests => 2;

    my $patron = $builder->build_object(
        { class => 'Koha::Patrons', value => { flags => 1 } } );
    my $password = Koha::AuthUtils::generate_password();
    $patron->update_password( $patron->userid, $password );
    $s->opac_auth( $patron->userid, $password );
    my $elt = $driver->find_element('//span[@class="loggedinusername"]');
    is( $elt->get_attribute('data-branchcode'), $patron->library->branchcode,
        "Since bug 20921 span.loggedinusername should contain data-branchcode"
    );
    is( $elt->get_attribute('data-borrowernumber'), $patron->borrowernumber,
"Since bug 20921 span.loggedinusername should contain data-borrowernumber"
    );
    push @cleanup, $patron, $patron->category, $patron->library;
};

subtest 'OPAC - Remove from cart' => sub {
    plan tests => 4;

    $driver->get( $opac_base_url . "opac-search.pl?q=d" );

    # A better way to do that would be to modify the way we display the basket count
    # We should show/hide the count instead or recreate the node
    my @basket_count_elts = $driver->find_elements('//span[@id="basketcount"]/span');
    is( scalar(@basket_count_elts), 0, 'Basket should be empty');

    # This will fail if nothing is indexed, but at this point we should have everything setup correctly
    my @checkboxes = $driver->find_elements('//input[@type="checkbox"][@name="biblionumber"]');
    my $biblionumber1 = $checkboxes[0]->get_value();
    my $biblionumber3 = $checkboxes[2]->get_value();
    my $biblionumber5 = $checkboxes[4]->get_value();

    $driver->find_element('//a[@class="addtocart cart'.$biblionumber1.'"]')->click;
    my $basket_count_elt = $driver->find_element('//span[@id="basketcount"]/span');
    is( $basket_count_elt->get_text(),
        1, 'One element should have been added to the cart' );

    $driver->find_element('//a[@class="addtocart cart'.$biblionumber3.'"]')->click;
    $driver->find_element('//a[@class="addtocart cart'.$biblionumber5.'"]')->click;
    $basket_count_elt = $driver->find_element('//span[@id="basketcount"]/span');
    is( $basket_count_elt->get_text(),
        3, '3 elements should have been added to the cart' );

    $driver->find_element('//a[@class="cartRemove cartR'.$biblionumber3.'"]')->click;
    $basket_count_elt = $driver->find_element('//span[@id="basketcount"]/span');
    is( $basket_count_elt->get_text(),
        2, '1 element should have been removed from the cart' );
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
    my $item = $builder->build_object(
        {
            class => 'Koha::Items',
            value => {
                biblionumber  => $biblionumber,
                homebranch    => $library->branchcode,
                holdingbranch => $library->branchcode,
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
            }
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
    $thead_length += $_->get_attribute('colspan') || 0 for @thead_th;

    my @tfoot_td = $driver->find_elements('//table[@id="issues-table"]/tfoot/tr/td');
    my $tfoot_length = 0;
    $tfoot_length += $_->get_attribute('colspan') || 0 for @tfoot_td;

    my @tbody_td = $driver->find_elements('//table[@id="issues-table"]/tbody/tr/td');
    my $tbody_length = 0;
    $tbody_length += $_->get_attribute('colspan') || 0 for @tbody_td;

    is( $thead_length == $tfoot_length && $tfoot_length == $tbody_length,
        1, "Checkouts table must be correctly aligned" )
      or diag(
        "thead: $thead_length ; tfoot: $tfoot_length ; tbody: $tbody_length");

    push @cleanup, $patron->checkouts, $item->biblio, $item, $patron,
      $patron->category, $library;
};

subtest 'XSS vulnerabilities in pagination' => sub {
    plan tests => 4;

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    for ( 1 .. 30 ) { # We want the pagination to be displayed
        push @cleanup, $builder->build_object(
            {
                class => 'Koha::Virtualshelves',
                value => {
                    category                 => 2,
                    allow_change_from_owner  => 1,
                    allow_change_from_others => 0,
                    owner                    => $patron->borrowernumber
                }
            }
        );
    }

    my $password = Koha::AuthUtils::generate_password();
    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
    $patron->set_password({ password => $password });
    $s->opac_auth( $patron->userid, $password );

    my $public_lists = $s->opac_base_url . q|opac-shelves.pl?op=list&category=2|;
    $driver->get($public_lists);

    $s->remove_error_handler;
    my $alert_text = eval { $driver->get_alert_text() };
    $s->add_error_handler;
    is( $alert_text, undef, 'No alert box displayed' );

    my $booh_alert = 'booh!';
    $public_lists = $s->opac_base_url . qq|opac-shelves.pl?op=list&category=2"><script>alert('$booh_alert')</script>|;
    $driver->get($public_lists);

    $s->remove_error_handler;
    $alert_text = eval { $driver->get_alert_text() };
    $s->add_error_handler;
    is( $alert_text, undef, 'No alert box displayed, even if evil intent' );

    my $second_page = $driver->find_element('//div[@class="pages"]/span[@class="currentPage"]/following-sibling::a');
    unlike( $second_page->get_attribute('href'), qr{%22%3E%3Cscript%3Ealert%28%27booh%21%27%29%3C%2Fscript%3E}, 'The second page link should not contain any script tags (escaped or otherwise)' );
    unlike( $second_page->get_attribute('href'), qr{"<script>alert('booh!')</script>}, 'The second page link should not contain any script tags (escaped or otherwise)' );

    push @cleanup, $patron, $patron->category, $patron->library;
};

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
