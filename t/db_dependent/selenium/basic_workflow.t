use Modern::Perl;

#die "Do NOT execute this script on a production server, it could affect your data\n Edit it and remove this line if you really want to use it";

use Time::HiRes qw(gettimeofday);
use C4::Context;
use C4::Biblio qw( AddBiblio ); # We shouldn't use it

use Selenium::Remote::Driver;
use Test::More tests => 20;
use MARC::Record;
use MARC::Field;

my $dbh = C4::Context->dbh;
my $login = 'koha';
my $password = 'koha';
my $base_url= 'http://'.C4::Context->preference("staffClientBaseURL")."/cgi-bin/koha/";

my $number_of_biblios_to_insert = 3;
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
        password   => 'password',
        password2  => 'password'
    },
};


#my $form_data;
#while ( my ($entity_name, $values) = each %$sample_data ) {
#    while ( my ( $field, $value ) = each %$values ) {
#        push @{ $form_data->{$entity_name} }, { field => $field, value => $value };
#    }
#}

open our $fh, '>>', '/tmp/output.txt';

my $driver = Selenium::Remote::Driver->new;
our $start = gettimeofday;
our $prev_time = $start;
$driver->get($base_url."mainpage.pl");
like( $driver->get_title(), qr(Log in to Koha), );
auth( $driver, $login, $password );
time_diff("main");

$driver->get($base_url.'admin/categories.pl');
like( $driver->get_title(), qr(Patron categories), );
$driver->find_element('//a[@id="newcategory"]')->click;
like( $driver->get_title(), qr(New category), );
fill_form( $driver, $sample_data->{category} );
$driver->find_element('//input[@type="button"]')->click;

time_diff("add patron category");
$driver->get($base_url.'/members/memberentry.pl?op=add&amp;categorycode='.$sample_data->{category}{categorycode});
like( $driver->get_title(), qr(Add .*$sample_data->{category}{description}), );
fill_form( $driver, $sample_data->{patron} );
$driver->find_element('//fieldset[@class="action"]/input[@type="submit"]')->click;
like( $driver->get_title(), qr(Patron details for $sample_data->{patron}{surname}), );

####$driver->get($base_url.'/members/members-home.pl');
####fill_form( $driver, { searchmember => $sample_data->{patron}{cardnumber} } );
####$driver->find_element('//div[@id="header_search"]/div/form/input[@type="submit"]')->click;
####like( $driver->get_title(), qr(Patron details for), );

time_diff("add patron");

our $borrowernumber = $dbh->selectcol_arrayref(q|SELECT borrowernumber FROM borrowers WHERE userid=?|, {}, $sample_data->{patron}{userid} );
$borrowernumber = $borrowernumber->[0];

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

my $itemtype = $dbh->selectcol_arrayref(q|SELECT itemtype FROM itemtypes|);
$itemtype = $itemtype->[0];

for my $biblionumber ( @biblionumbers ) {
    $driver->get($base_url."/cataloguing/additem.pl?biblionumber=$biblionumber");
    like( $driver->get_title(), qr(test biblio \d+ by test author), );
    my $form = $driver->find_element('//form[@name="f"]');
    my $inputs = $driver->find_child_elements($form, '//input[@type="text"]');
    for my $input ( @$inputs ) {
        next if $input->is_hidden();
        $input->send_keys('t_value_bib'.$biblionumber);
    }

    $driver->find_element('//input[@name="add_submit"]')->click;
    like( $driver->get_title(), qr($biblionumber.*Items) );

    $dbh->do(q|UPDATE items SET notforloan=0 WHERE biblionumber=?|, {}, $biblionumber );
    $dbh->do(q|UPDATE biblioitems SET itemtype=? WHERE biblionumber=?|, {}, $itemtype, $biblionumber);
    $dbh->do(q|UPDATE items SET itype=? WHERE biblionumber=?|, {}, $itemtype, $biblionumber);
}

time_diff("add items");

my $nb_of_checkouts = 0;
for my $biblionumber ( @biblionumbers ) {
    $driver->get($base_url."/circ/circulation.pl?borrowernumber=".$borrowernumber);
    $driver->find_element('//input[@id="barcode"]')->send_keys('t_value_bib'.$biblionumber);
    $driver->find_element('//fieldset[@id="circ_circulation_issue"]/button[@type="submit"]')->click;
    $nb_of_checkouts++;
    like( $driver->get_title(), qr(Checking out to $sample_data->{patron}{surname}) );
    is( $driver->find_element('//a[@href="#checkouts"]')->get_attribute('text'), $nb_of_checkouts.' Checkout(s)', );
}

time_diff("checkout");

for my $biblionumber ( @biblionumbers ) {
    $driver->get($base_url."/circ/returns.pl");
    $driver->find_element('//input[@id="barcode"]')->send_keys('t_value_bib'.$biblionumber);
    $driver->find_element('//form[@id="checkin-form"]/div/fieldset/input[@type="submit"]')->click;
    like( $driver->get_title(), qr(Check in test biblio \d+) );
}

time_diff("checkin");

close $fh;
$driver->quit();

END {
    cleanup();
};

sub auth {
    my ( $driver, $login, $password) = @_;
    fill_form( $driver, { userid => 'koha', password => 'koha' } );
    my $login_button = $driver->find_element('//input[@id="submit"]');
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
    for my $i ( 1 .. $number_of_biblios_to_insert ) {
        $dbh->do(qq|DELETE FROM biblio WHERE title = "test biblio $i"|);
    };

    $dbh->do(q|DELETE FROM issues where borrowernumber=?|, {}, $borrowernumber);
    $dbh->do(q|DELETE FROM old_issues where borrowernumber=?|, {}, $borrowernumber);
    for my $i ( 1 .. $number_of_biblios_to_insert ) {
        $dbh->do(qq|DELETE items, biblio FROM biblio INNER JOIN items ON biblio.biblionumber = items.biblionumber WHERE biblio.title = "test biblio$i"|);
    };
}

sub time_diff {
    my $lib = shift;
    my $now = gettimeofday;
    warn "CP $lib = " . sprintf("%.2f", $now - $prev_time ) . "\n";
    $prev_time = $now;
}
