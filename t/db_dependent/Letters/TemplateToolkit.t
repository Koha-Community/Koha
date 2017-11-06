#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2016 ByWater Solutions
# Copyright (C) 2017 Koha Development Team
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
use Test::More tests => 18;
use Test::Warn;

use MARC::Record;

use t::lib::TestBuilder;

use C4::Circulation;
use C4::Letters;
use C4::Members;
use C4::Biblio;
use Koha::Database;
use Koha::DateUtils;
use Koha::ArticleRequests;
use Koha::Biblio;
use Koha::Biblioitem;
use Koha::Item;
use Koha::Hold;
use Koha::NewsItem;
use Koha::Serial;
use Koha::Subscription;
use Koha::Suggestion;
use Koha::Checkout;
use Koha::Notice::Messages;
use Koha::Notice::Templates;
use Koha::Patron::Modification;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin();

my $builder = t::lib::TestBuilder->new();

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM letter|);

my $date = dt_from_string;

my $library = $builder->build( { source => 'Branch' } );
my $patron  = $builder->build( { source => 'Borrower' } );
my $patron2 = $builder->build( { source => 'Borrower' } );

my $biblio = Koha::Biblio->new(
    {
        title => 'Test Biblio'
    }
)->store();

my $biblioitem = Koha::Biblioitem->new(
    {
        biblionumber => $biblio->id()
    }
)->store();

my $item = Koha::Item->new(
    {
        biblionumber     => $biblio->id(),
        biblioitemnumber => $biblioitem->id()
    }
)->store();

my $hold = Koha::Hold->new(
    {
        borrowernumber => $patron->{borrowernumber},
        biblionumber   => $biblio->id()
    }
)->store();

my $news         = Koha::NewsItem->new({ title => 'a news title', content => 'a news content'})->store();
my $serial       = Koha::Serial->new()->store();
my $subscription = Koha::Subscription->new()->store();
my $suggestion   = Koha::Suggestion->new()->store();
my $checkout     = Koha::Checkout->new( { itemnumber => $item->id() } )->store();
my $modification = Koha::Patron::Modification->new( { verification_token => "TEST" } )->store();

my $prepared_letter;

my $sth =
  $dbh->prepare(q{INSERT INTO letter (module, code, name, title, content) VALUES ('test',?,'Test','Test',?)});

$sth->execute( "TEST_PATRON", "[% borrower.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_PATRON',
        tables      => {
            borrowers => $patron->{borrowernumber},
        },
    )
);
is( $prepared_letter->{content}, $patron->{borrowernumber}, 'Patron object used correctly with scalar' );

$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_PATRON',
        tables      => {
            borrowers => $patron,
        },
    )
);
is( $prepared_letter->{content}, $patron->{borrowernumber}, 'Patron object used correctly with hashref' );

$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_PATRON',
        tables      => {
            borrowers => [ $patron->{borrowernumber} ],
        },
    )
);
is( $prepared_letter->{content}, $patron->{borrowernumber}, 'Patron object used correctly with arrayref' );

$sth->execute( "TEST_BIBLIO", "[% biblio.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_BIBLIO',
        tables      => {
            biblio => $biblio->id(),
        },
    )
);
is( $prepared_letter->{content}, $biblio->id, 'Biblio object used correctly' );

$sth->execute( "TEST_LIBRARY", "[% branch.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_LIBRARY',
        tables      => {
            branches => $library->{branchcode}
        },
    )
);
is( $prepared_letter->{content}, $library->{branchcode}, 'Library object used correctly' );

$sth->execute( "TEST_ITEM", "[% item.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_ITEM',
        tables      => {
            items => $item->id()
        },
    )
);
is( $prepared_letter->{content}, $item->id(), 'Item object used correctly' );

$sth->execute( "TEST_NEWS", "[% news.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_NEWS',
        tables      => {
            opac_news => $news->id()
        },
    )
);
is( $prepared_letter->{content}, $news->id(), 'News object used correctly' );

$sth->execute( "TEST_HOLD", "[% hold.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_HOLD',
        tables      => {
            reserves => { borrowernumber => $patron->{borrowernumber}, biblionumber => $biblio->id() },
        },
    )
);
is( $prepared_letter->{content}, $hold->id(), 'Hold object used correctly' );

eval {
    $prepared_letter = GetPreparedLetter(
        (
            module      => 'test',
            letter_code => 'TEST_HOLD',
            tables      => {
                reserves => [ $patron->{borrowernumber}, $biblio->id() ],
            },
        )
    )
};
my $croak = $@;
like( $croak, qr{^Multiple foreign keys \(table reserves\) should be passed using an hashref.*}, "GetPreparedLetter should not be called with arrayref for multiple FK" );

# Bug 16942
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_HOLD',
        tables      => {
            'branches'    => $library,
            'borrowers'   => $patron,
            'biblio'      => $biblio->id,
            'biblioitems' => $biblioitem->id,
            'reserves'    => $hold->unblessed,
            'items'       => $hold->itemnumber,
        }
    )
);
is( $prepared_letter->{content}, $hold->id(), 'Hold object used correctly' );

$sth->execute( "TEST_SERIAL", "[% serial.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_SERIAL',
        tables      => {
            serial => $serial->id()
        },
    )
);
is( $prepared_letter->{content}, $serial->id(), 'Serial object used correctly' );

$sth->execute( "TEST_SUBSCRIPTION", "[% subscription.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_SUBSCRIPTION',
        tables      => {
            subscription => $subscription->id()
        },
    )
);
is( $prepared_letter->{content}, $subscription->id(), 'Subscription object used correctly' );

$sth->execute( "TEST_SUGGESTION", "[% suggestion.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_SUGGESTION',
        tables      => {
            suggestions => $suggestion->id()
        },
    )
);
is( $prepared_letter->{content}, $suggestion->id(), 'Suggestion object used correctly' );

$sth->execute( "TEST_ISSUE", "[% checkout.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_ISSUE',
        tables      => {
            issues => $item->id()
        },
    )
);
is( $prepared_letter->{content}, $checkout->id(), 'Checkout object used correctly' );

$sth->execute( "TEST_MODIFICATION", "[% patron_modification.id %]" );
$prepared_letter = GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_MODIFICATION',
        tables      => {
            borrower_modifications => $modification->verification_token,
        },
    )
);
is( $prepared_letter->{content}, $modification->id(), 'Patron modification object used correctly' );

subtest 'regression tests' => sub {
    plan tests => 7;

    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build( { source => 'Borrower' } );
    my $biblio1 = Koha::Biblio->new({title => 'Test Biblio 1', author => 'An author', })->store->unblessed;
    my $biblioitem1 = Koha::Biblioitem->new({biblionumber => $biblio1->{biblionumber}})->store()->unblessed;
    my $item1 = Koha::Item->new(
        {
            biblionumber     => $biblio1->{biblionumber},
            biblioitemnumber => $biblioitem1->{biblioitemnumber},
            barcode          => 'a_t_barcode',
            homebranch       => $library->{branchcode},
            holdingbranch    => $library->{branchcode},
            itype            => 'BK',
            itemcallnumber   => 'itemcallnumber1',
        }
    )->store->unblessed;
    my $biblio2 = Koha::Biblio->new({title => 'Test Biblio 2'})->store->unblessed;
    my $biblioitem2 = Koha::Biblioitem->new({biblionumber => $biblio2->{biblionumber}})->store()->unblessed;
    my $item2 = Koha::Item->new(
        {
            biblionumber     => $biblio2->{biblionumber},
            biblioitemnumber => $biblioitem2->{biblioitemnumber},
            barcode          => 'another_t_barcode',
            homebranch       => $library->{branchcode},
            holdingbranch    => $library->{branchcode},
            itype            => 'BK',
            itemcallnumber   => 'itemcallnumber2',
        }
    )->store->unblessed;
    my $biblio3 = Koha::Biblio->new({title => 'Test Biblio 3'})->store->unblessed;
    my $biblioitem3 = Koha::Biblioitem->new({biblionumber => $biblio3->{biblionumber}})->store()->unblessed;
    my $item3 = Koha::Item->new(
        {
            biblionumber     => $biblio3->{biblionumber},
            biblioitemnumber => $biblioitem3->{biblioitemnumber},
            barcode          => 'another_t_barcode_3',
            homebranch       => $library->{branchcode},
            holdingbranch    => $library->{branchcode},
            itype            => 'BK',
            itemcallnumber   => 'itemcallnumber3',
        }
    )->store->unblessed;

    C4::Context->_new_userenv('xxx');
    C4::Context->set_userenv(0,0,0,'firstname','surname', $library->{branchcode}, 'Midway Public Library', '', '', '');

    subtest 'ACQ_NOTIF_ON_RECEIV ' => sub {
        plan tests => 1;
        my $code = 'ACQ_NOTIF_ON_RECEIV';
        my $branchcode = $library->{branchcode};
        my $order = $builder->build({ source => 'Aqorder' });

        my $template = q|
Dear <<borrowers.firstname>> <<borrowers.surname>>,
The order <<aqorders.ordernumber>> (<<biblio.title>>) has been received.
Your library.
        |;
        my $params = { code => $code, branchcode => $branchcode, tables => { branches => $library, borrowers => $patron, biblio => $biblio1, aqorders => $order } };
        my $letter = process_letter( { template => $template, %$params });
        my $tt_template = q|
Dear [% borrower.firstname %] [% borrower.surname %],
The order [% order.ordernumber %] ([% biblio.title %]) has been received.
Your library.
        |;
        my $tt_letter = process_letter( { template => $tt_template, %$params });

        is( $tt_letter->{content}, $letter->{content}, 'Verified letter content' );
    };

    subtest 'AR_*' => sub {
        plan tests => 2;
        my $code = 'AR_CANCELED';
        my $branchcode = $library->{branchcode};

        my $template = q|
<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)

Your request for an article from <<biblio.title>> (<<items.barcode>>) has been canceled for the following reason:

<<article_requests.notes>>

Article requested:
Title: <<article_requests.title>>
Author: <<article_requests.author>>
Volume: <<article_requests.volume>>
Issue: <<article_requests.issue>>
Date: <<article_requests.date>>
Pages: <<article_requests.pages>>
Chapters: <<article_requests.chapters>>
Notes: <<article_requests.patron_notes>>
        |;
        reset_template( { template => $template, code => $code, module => 'circulation' } );
        my $article_request = $builder->build({ source => 'ArticleRequest' });
        Koha::ArticleRequests->find( $article_request->{id} )->cancel;
        my $letter = Koha::Notice::Messages->search( {}, { order_by => { -desc => 'message_id' } } )->next;

        my $tt_template = q|
[% borrower.firstname %] [% borrower.surname %] ([% borrower.cardnumber %])

Your request for an article from [% biblio.title %] ([% item.barcode %]) has been canceled for the following reason:

[% article_request.notes %]

Article requested:
Title: [% article_request.title %]
Author: [% article_request.author %]
Volume: [% article_request.volume %]
Issue: [% article_request.issue %]
Date: [% article_request.date %]
Pages: [% article_request.pages %]
Chapters: [% article_request.chapters %]
Notes: [% article_request.patron_notes %]
        |;
        reset_template( { template => $tt_template, code => $code, module => 'circulation' } );
        Koha::ArticleRequests->find( $article_request->{id} )->cancel;
        my $tt_letter = Koha::Notice::Messages->search( {}, { order_by => { -desc => 'message_id' } } )->next;
        is( $tt_letter->content, $letter->content, 'Compare AR_* notices' );
        isnt( $tt_letter->message_id, $letter->message_id, 'Comparing AR_* notices should compare 2 different messages' );
    };

    subtest 'CHECKOUT+CHECKIN' => sub {
        plan tests => 4;

        my $checkout_code = 'CHECKOUT';
        my $checkin_code = 'CHECKIN';

        my $dbh = C4::Context->dbh;
        # Enable notification for CHECKOUT - Things are hardcoded here but should work with default data
        $dbh->do(q|INSERT INTO borrower_message_preferences( borrowernumber, message_attribute_id ) VALUES ( ?, ? )|, undef, $patron->{borrowernumber}, 6 );
        my $borrower_message_preference_id = $dbh->last_insert_id(undef, undef, "borrower_message_preferences", undef);
        $dbh->do(q|INSERT INTO borrower_message_transport_preferences( borrower_message_preference_id, message_transport_type) VALUES ( ?, ? )|, undef, $borrower_message_preference_id, 'email' );
        # Enable notification for CHECKIN - Things are hardcoded here but should work with default data
        $dbh->do(q|INSERT INTO borrower_message_preferences( borrowernumber, message_attribute_id ) VALUES ( ?, ? )|, undef, $patron->{borrowernumber}, 5 );
        $borrower_message_preference_id = $dbh->last_insert_id(undef, undef, "borrower_message_preferences", undef);
        $dbh->do(q|INSERT INTO borrower_message_transport_preferences( borrower_message_preference_id, message_transport_type) VALUES ( ?, ? )|, undef, $borrower_message_preference_id, 'email' );

        # historic syntax
        my $checkout_template = q|
The following items have been checked out:
----
<<biblio.title>>
----
Thank you for visiting <<branches.branchname>>.
|;
        reset_template( { template => $checkout_template, code => $checkout_code, module => 'circulation' } );
        my $checkin_template = q[
The following items have been checked out:
----
<<biblio.title>> was due on <<old_issues.date_due | dateonly>>
----
Thank you for visiting <<branches.branchname>>.
];
        reset_template( { template => $checkin_template, code => $checkin_code, module => 'circulation' } );

        C4::Circulation::AddIssue( $patron, $item1->{barcode} );
        my $first_checkout_letter = Koha::Notice::Messages->search( {}, { order_by => { -desc => 'message_id' } } )->next;
        C4::Circulation::AddIssue( $patron, $item2->{barcode} );
        my $second_checkout_letter = Koha::Notice::Messages->search( {}, { order_by => { -desc => 'message_id' } } )->next;

        AddReturn( $item1->{barcode} );
        my $first_checkin_letter = Koha::Notice::Messages->search( {}, { order_by => { -desc => 'message_id' } } )->next;
        AddReturn( $item2->{barcode} );
        my $second_checkin_letter = Koha::Notice::Messages->search( {}, { order_by => { -desc => 'message_id' } } )->next;

        Koha::Notice::Messages->delete;

        # TT syntax
        $checkout_template = q|
The following items have been checked out:
----
[% biblio.title %]
----
Thank you for visiting [% branch.branchname %].
|;
        reset_template( { template => $checkout_template, code => $checkout_code, module => 'circulation' } );
        $checkin_template = q[
The following items have been checked out:
----
[% biblio.title %] was due on [% old_checkout.date_due | $KohaDates %]
----
Thank you for visiting [% branch.branchname %].
];
        reset_template( { template => $checkin_template, code => $checkin_code, module => 'circulation' } );

        C4::Circulation::AddIssue( $patron, $item1->{barcode} );
        my $first_checkout_tt_letter = Koha::Notice::Messages->search( {}, { order_by => { -desc => 'message_id' } } )->next;
        C4::Circulation::AddIssue( $patron, $item2->{barcode} );
        my $second_checkout_tt_letter = Koha::Notice::Messages->search( {}, { order_by => { -desc => 'message_id' } } )->next;

        AddReturn( $item1->{barcode} );
        my $first_checkin_tt_letter = Koha::Notice::Messages->search( {}, { order_by => { -desc => 'message_id' } } )->next;
        AddReturn( $item2->{barcode} );
        my $second_checkin_tt_letter = Koha::Notice::Messages->search( {}, { order_by => { -desc => 'message_id' } } )->next;

        is( $first_checkout_tt_letter->content, $first_checkout_letter->content, 'Verify first checkout letter' );
        is( $second_checkout_tt_letter->content, $second_checkout_letter->content, 'Verify second checkout letter' );
        is( $first_checkin_tt_letter->content, $first_checkin_letter->content, 'Verify first checkin letter'  );
        is( $second_checkin_tt_letter->content, $second_checkin_letter->content, 'Verify second checkin letter' );

    };

    subtest 'DUEDGST|count' => sub {
        plan tests => 1;

        my $code = 'DUEDGST';

        my $dbh = C4::Context->dbh;
        # Enable notification for DUEDGST - Things are hardcoded here but should work with default data
        $dbh->do(q|INSERT INTO borrower_message_preferences( borrowernumber, message_attribute_id ) VALUES ( ?, ? )|, undef, $patron->{borrowernumber}, 1 );
        my $borrower_message_preference_id = $dbh->last_insert_id(undef, undef, "borrower_message_preferences", undef);
        $dbh->do(q|INSERT INTO borrower_message_transport_preferences( borrower_message_preference_id, message_transport_type) VALUES ( ?, ? )|, undef, $borrower_message_preference_id, 'email' );

        my $params = {
            code => $code,
            substitute => { count => 42 },
        };

        my $template = q|
You have <<count>> items due
        |;
        my $letter = process_letter( { template => $template, %$params });

        my $tt_template = q|
You have [% count %] items due
        |;
        my $tt_letter = process_letter( { template => $tt_template, %$params });
        is( $tt_letter->{content}, $letter->{content}, );
    };

    subtest 'HOLD_SLIP|dates|today' => sub {
        plan tests => 2;

        my $code = 'HOLD_SLIP';

        C4::Reserves::AddReserve( $library->{branchcode}, $patron->{borrowernumber}, $biblio1->{biblionumber}, undef, undef, undef, undef, "a note", undef, $item1->{itemnumber}, 'W' );
        C4::Reserves::AddReserve( $library->{branchcode}, $patron->{borrowernumber}, $biblio2->{biblionumber}, undef, undef, undef, undef, "another note", undef, $item2->{itemnumber} );

        my $template = <<EOF;
<h5>Date: <<today>></h5>

<h3> Transfer to/Hold in <<branches.branchname>></h3>

<h3><<borrowers.surname>>, <<borrowers.firstname>></h3>

<ul>
    <li><<borrowers.cardnumber>></li>
    <li><<borrowers.phone>></li>
    <li> <<borrowers.address>><br />
         <<borrowers.address2>><br />
         <<borrowers.city>>  <<borrowers.zipcode>>
    </li>
    <li><<borrowers.email>></li>
</ul>
<br />
<h3>ITEM ON HOLD</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
   <li><<reserves.waitingdate>></li>
</ul>
<p>Notes:
<pre><<reserves.reservenotes>></pre>
</p>
EOF

        reset_template( { template => $template, code => $code, module => 'circulation' } );
        my $letter_for_item1 = C4::Reserves::ReserveSlip( $library->{branchcode}, $patron->{borrowernumber}, $biblio1->{biblionumber} );
        my $letter_for_item2 = C4::Reserves::ReserveSlip( $library->{branchcode}, $patron->{borrowernumber}, $biblio2->{biblionumber} );

        my $tt_template = <<EOF;
<h5>Date: [% today | \$KohaDates with_hours => 1 %]</h5>

<h3> Transfer to/Hold in [% branch.branchname %]</h3>

<h3>[% borrower.surname %], [% borrower.firstname %]</h3>

<ul>
    <li>[% borrower.cardnumber %]</li>
    <li>[% borrower.phone %]</li>
    <li> [% borrower.address %]<br />
         [% borrower.address2 %]<br />
         [% borrower.city %]  [% borrower.zipcode %]
    </li>
    <li>[% borrower.email %]</li>
</ul>
<br />
<h3>ITEM ON HOLD</h3>
<h4>[% biblio.title %]</h4>
<h5>[% biblio.author %]</h5>
<ul>
   <li>[% item.barcode %]</li>
   <li>[% item.itemcallnumber %]</li>
   <li>[% hold.waitingdate | \$KohaDates %]</li>
</ul>
<p>Notes:
<pre>[% hold.reservenotes %]</pre>
</p>
EOF

        reset_template( { template => $tt_template, code => $code, module => 'circulation' } );
        my $tt_letter_for_item1 = C4::Reserves::ReserveSlip( $library->{branchcode}, $patron->{borrowernumber}, $biblio1->{biblionumber} );
        my $tt_letter_for_item2 = C4::Reserves::ReserveSlip( $library->{branchcode}, $patron->{borrowernumber}, $biblio2->{biblionumber} );

        is( $tt_letter_for_item1->{content}, $letter_for_item1->{content}, );
        is( $tt_letter_for_item2->{content}, $letter_for_item2->{content}, );
    };

    subtest 'ISSUESLIP|checkedout|repeat' => sub {
        plan tests => 2;

        my $code = 'ISSUESLIP';
        my $now = dt_from_string;
        my $one_minute_ago = dt_from_string->subtract( minutes => 1 );

        my $branchcode = $library->{branchcode};

        Koha::News->delete;
        my $news_item = Koha::NewsItem->new({ branchcode => $branchcode, title => "A wonderful news", content => "This is the wonderful news." })->store;

        # historic syntax
        my $template = <<EOF;
<h3><<branches.branchname>></h3>
Checked out to <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(<<borrowers.cardnumber>>) <br />

<<today>><br />

<h4>Checked Out</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Barcode: <<items.barcode>><br />
Date due: <<issues.date_due | dateonly>><br />
</p>
</checkedout>

<h4>Overdues</h4>
<overdue>
<p>
<<biblio.title>> <br />
Barcode: <<items.barcode>><br />
Date due: <<issues.date_due | dateonly>><br />
</p>
</overdue>

<hr>

<h4 style="text-align: center; font-style:italic;">News</h4>
<news>
<div class="newsitem">
<h5 style="margin-bottom: 1px; margin-top: 1px"><b><<opac_news.title>></b></h5>
<p style="margin-bottom: 1px; margin-top: 1px"><<opac_news.content>></p>
<p class="newsfooter" style="font-size: 8pt; font-style:italic; margin-bottom: 1px; margin-top: 1px">Posted on <<opac_news.timestamp>></p>
<hr />
</div>
</news>
EOF

        reset_template( { template => $template, code => $code, module => 'circulation' } );

        my $checkout = C4::Circulation::AddIssue( $patron, $item1->{barcode} ); # Add a first checkout
        $checkout->set_columns( { timestamp => $now, issuedate => $one_minute_ago } )->update; # FIXME $checkout is a Koha::Schema::Result::Issues, must be a Koha::Checkout
        my $first_slip = C4::Members::IssueSlip( $branchcode, $patron->{borrowernumber} );

        $checkout = C4::Circulation::AddIssue( $patron, $item2->{barcode} ); # Add a second checkout
        $checkout->set_columns( { timestamp => $now, issuedate => $now } )->update;
        my $yesterday = dt_from_string->subtract( days => 1 );
        C4::Circulation::AddIssue( $patron, $item3->{barcode}, $yesterday ); # Add an overdue
        my $second_slip = C4::Members::IssueSlip( $branchcode, $patron->{borrowernumber} );

        # Cleanup
        AddReturn( $item1->{barcode} );
        AddReturn( $item2->{barcode} );
        AddReturn( $item3->{barcode} );

        # TT syntax
        my $tt_template = <<EOF;
<h3>[% branch.branchname %]</h3>
Checked out to [% borrower.title %] [% borrower.firstname %] [% borrower.initials %] [% borrower.surname %] <br />
([% borrower.cardnumber %]) <br />

[% today | \$KohaDates with_hours => 1 %]<br />

<h4>Checked Out</h4>
[% FOREACH checkout IN checkouts %]
[%~ SET item = checkout.item %]
[%~ SET biblio = checkout.item.biblio %]
<p>
[% biblio.title %] <br />
Barcode: [% item.barcode %]<br />
Date due: [% checkout.date_due | \$KohaDates %]<br />
</p>
[% END %]

<h4>Overdues</h4>
[% FOREACH overdue IN overdues %]
[%~ SET item = overdue.item %]
[%~ SET biblio = overdue.item.biblio %]
<p>
[% biblio.title %] <br />
Barcode: [% item.barcode %]<br />
Date due: [% overdue.date_due | \$KohaDates %]<br />
</p>
[% END %]

<hr>

<h4 style="text-align: center; font-style:italic;">News</h4>
[% FOREACH n IN news %]
<div class="newsitem">
<h5 style="margin-bottom: 1px; margin-top: 1px"><b>[% n.title %]</b></h5>
<p style="margin-bottom: 1px; margin-top: 1px">[% n.content %]</p>
<p class="newsfooter" style="font-size: 8pt; font-style:italic; margin-bottom: 1px; margin-top: 1px">Posted on [% n.timestamp | \$KohaDates %]</p>
<hr />
</div>
[% END %]
EOF

        reset_template( { template => $tt_template, code => $code, module => 'circulation' } );

        $checkout = C4::Circulation::AddIssue( $patron, $item1->{barcode} ); # Add a first checkout
        $checkout->set_columns( { timestamp => $now, issuedate => $one_minute_ago } )->update;
        my $first_tt_slip = C4::Members::IssueSlip( $branchcode, $patron->{borrowernumber} );

        $checkout = C4::Circulation::AddIssue( $patron, $item2->{barcode} ); # Add a second checkout
        $checkout->set_columns( { timestamp => $now, issuedate => $now } )->update;
        C4::Circulation::AddIssue( $patron, $item3->{barcode}, $yesterday ); # Add an overdue
        my $second_tt_slip = C4::Members::IssueSlip( $branchcode, $patron->{borrowernumber} );

        # There is too many line breaks generated by the historic syntax
        $second_slip->{content} =~ s|</p>\n\n\n<p>|</p>\n\n<p>|s;

        is( $first_tt_slip->{content}, $first_slip->{content}, );
        is( $second_tt_slip->{content}, $second_slip->{content}, );

        # Cleanup
        AddReturn( $item1->{barcode} );
        AddReturn( $item2->{barcode} );
        AddReturn( $item3->{barcode} );
    };

    subtest 'ODUE|items.content|item' => sub {
        plan tests => 1;

        my $code = 'ODUE';

        my $branchcode = $library->{branchcode};

        # historic syntax
        # FIXME items.fine does not work with TT notices
        # See bug 17976
        # <item> should contain Fine: <<items.fine>></item>
        my $template = <<EOF;
Dear <<borrowers.firstname>> <<borrowers.surname>>,

According to our current records, you have items that are overdue.Your library does not charge late fines, but please return or renew them at the branch below as soon as possible.

<<branches.branchname>>
<<branches.branchaddress1>>
<<branches.branchaddress2>> <<branches.branchaddress3>>
Phone: <<branches.branchphone>>
Fax: <<branches.branchfax>>
Email: <<branches.branchemail>>

If you have registered a password with the library, and you have a renewal available, you may renew online. If an item becomes more than 30 days overdue, you will be unable to use your library card until the item is returned.

The following item(s) is/are currently overdue:

<item>"<<biblio.title>>" by <<biblio.author>>, <<items.itemcallnumber>>, Barcode: <<items.barcode>></item>

<<items.content>>

Thank-you for your prompt attention to this matter.

<<branches.branchname>> Staff
EOF

        reset_template( { template => $template, code => $code, module => 'circulation' } );

        my $yesterday = dt_from_string->subtract( days => 1 );
        my $two_days_ago = dt_from_string->subtract( days => 2 );
        my $issue1 = C4::Circulation::AddIssue( $patron, $item1->{barcode} ); # Add a first checkout
        my $issue2 = C4::Circulation::AddIssue( $patron, $item2->{barcode}, $yesterday ); # Add an first overdue
        my $issue3 = C4::Circulation::AddIssue( $patron, $item3->{barcode}, $two_days_ago ); # Add an second overdue
        $issue1 = Koha::Checkout->_new_from_dbic( $issue1 )->unblessed; # ->unblessed should be enough but AddIssue does not return a Koha::Checkout object
        $issue2 = Koha::Checkout->_new_from_dbic( $issue2 )->unblessed;
        $issue3 = Koha::Checkout->_new_from_dbic( $issue3 )->unblessed;

        # For items.content
        my @item_fields = qw( date_due title barcode author itemnumber );
        my $items_content = C4::Letters::get_item_content( { item => { %$item1, %$biblio1, %$issue1 }, item_content_fields => \@item_fields, dateonly => 1 } );
          $items_content .= C4::Letters::get_item_content( { item => { %$item2, %$biblio2, %$issue2 }, item_content_fields => \@item_fields, dateonly => 1 } );
          $items_content .= C4::Letters::get_item_content( { item => { %$item3, %$biblio3, %$issue3 }, item_content_fields => \@item_fields, dateonly => 1 } );

        my @items = ( $item1, $item2, $item3 );
        my $letter = C4::Overdues::parse_overdues_letter(
            {
                letter_code => $code,
                borrowernumber => $patron->{borrowernumber},
                branchcode  => $library->{branchcode},
                items       => \@items,
                substitute  => {
                    bib                    => $library->{branchname},
                    'items.content'        => $items_content,
                    count                  => scalar( @items ),
                    message_transport_type => 'email',
                }
            }
        );

        # Cleanup
        AddReturn( $item1->{barcode} );
        AddReturn( $item2->{barcode} );
        AddReturn( $item3->{barcode} );


        # historic syntax
        my $tt_template = <<EOF;
Dear [% borrower.firstname %] [% borrower.surname %],

According to our current records, you have items that are overdue.Your library does not charge late fines, but please return or renew them at the branch below as soon as possible.

[% branch.branchname %]
[% branch.branchaddress1 %]
[% branch.branchaddress2 %] [% branch.branchaddress3 %]
Phone: [% branch.branchphone %]
Fax: [% branch.branchfax %]
Email: [% branch.branchemail %]

If you have registered a password with the library, and you have a renewal available, you may renew online. If an item becomes more than 30 days overdue, you will be unable to use your library card until the item is returned.

The following item(s) is/are currently overdue:

[% FOREACH overdue IN overdues %]
[%~ SET item = overdue.item ~%]
"[% item.biblio.title %]" by [% item.biblio.author %], [% item.itemcallnumber %], Barcode: [% item.barcode %]
[% END %]
[% FOREACH overdue IN overdues %]
[%~ SET item = overdue.item ~%]
[% overdue.date_due | \$KohaDates %]\t[% item.biblio.title %]\t[% item.barcode %]\t[% item.biblio.author %]\t[% item.itemnumber %]
[% END %]

Thank-you for your prompt attention to this matter.

[% branch.branchname %] Staff
EOF

        reset_template( { template => $tt_template, code => $code, module => 'circulation' } );

        C4::Circulation::AddIssue( $patron, $item1->{barcode} ); # Add a first checkout
        C4::Circulation::AddIssue( $patron, $item2->{barcode}, $yesterday ); # Add an first overdue
        C4::Circulation::AddIssue( $patron, $item3->{barcode}, $two_days_ago ); # Add an second overdue

        my $tt_letter = C4::Overdues::parse_overdues_letter(
            {
                letter_code => $code,
                borrowernumber => $patron->{borrowernumber},
                branchcode  => $library->{branchcode},
                items       => \@items,
                substitute  => {
                    bib                    => $library->{branchname},
                    'items.content'        => $items_content,
                    count                  => scalar( @items ),
                    message_transport_type => 'email',
                }
            }
        );

        is( $tt_letter->{content}, $letter->{content}, );
    };

};

subtest 'loops' => sub {
    plan tests => 2;
    my $code = "TEST";
    my $module = "TEST";

    subtest 'primary key is AI' => sub {
        plan tests => 1;
        my $patron_1 = $builder->build({ source => 'Borrower' });
        my $patron_2 = $builder->build({ source => 'Borrower' });

        my $template = q|[% FOREACH patron IN borrowers %][% patron.surname %][% END %]|;
        reset_template( { template => $template, code => $code, module => $module } );
        my $letter = GetPreparedLetter( module => $module, letter_code => $code, loops => { borrowers => [ $patron_1->{borrowernumber}, $patron_2->{borrowernumber} ] } );
        my $expected_letter = join '', ( $patron_1->{surname}, $patron_2->{surname} );
        is( $letter->{content}, $expected_letter, );
    };

    subtest 'foreign key is used' => sub {
        plan tests => 1;
        my $patron_1 = $builder->build({ source => 'Borrower' });
        my $patron_2 = $builder->build({ source => 'Borrower' });
        my $checkout_1 = $builder->build({ source => 'Issue', value => { borrowernumber => $patron_1->{borrowernumber} } } );
        my $checkout_2 = $builder->build({ source => 'Issue', value => { borrowernumber => $patron_1->{borrowernumber} } } );

        my $template = q|[% FOREACH checkout IN checkouts %][% checkout.issue_id %][% END %]|;
        reset_template( { template => $template, code => $code, module => $module } );
        my $letter = GetPreparedLetter( module => $module, letter_code => $code, loops => { issues => [ $checkout_1->{itemnumber}, $checkout_2->{itemnumber} ] } );
        my $expected_letter = join '', ( $checkout_1->{issue_id}, $checkout_2->{issue_id} );
        is( $letter->{content}, $expected_letter, );
    };
};

subtest 'add_tt_filters' => sub {
    plan tests => 1;
    my $code   = "TEST";
    my $module = "TEST";

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { surname => "with_punctuation_" }
        }
    );
    my $biblio = $builder->build_object(
        { class => 'Koha::Biblios', value => { title => "with_punctuation_" } }
    );
    my $biblioitem = $builder->build_object(
        {
            class => 'Koha::Biblioitems',
            value => {
                biblionumber => $biblio->biblionumber,
                isbn         => "with_punctuation_"
            }
        }
    );

    my $template = q|patron=[% borrower.surname %];biblio=[% biblio.title %];biblioitems=[% biblioitem.isbn %]|;
    reset_template( { template => $template, code => $code, module => $module } );
    my $letter = GetPreparedLetter(
        module      => $module,
        letter_code => $code,
        tables      => {
            borrowers   => $patron->borrowernumber,
            biblio      => $biblio->biblionumber,
            biblioitems => $biblioitem->biblioitemnumber
        }
    );
    my $expected_letter = q|patron=with_punctuation_;biblio=with_punctuation;biblioitems=with_punctuation|;
    is( $letter->{content}, $expected_letter, "Pre-processing should call TT plugin to remove punctuation if table is biblio or biblioitems");
};


sub reset_template {
    my ( $params ) = @_;
    my $template   = $params->{template};
    my $code       = $params->{code};
    my $module     = $params->{module} || 'test_module';

    Koha::Notice::Templates->search( { code => $code } )->delete;
    Koha::Notice::Template->new(
        {
            module                 => $module,
            code                   => $code,
            branchcode             => '',
            name                   => $code,
            title                  => $code,
            message_transport_type => 'email',
            content                => $template
        }
    )->store;
}

sub process_letter {
    my ($params)   = @_;
    my $template   = $params->{template};
    my $tables     = $params->{tables};
    my $substitute = $params->{substitute};
    my $code       = $params->{code};
    my $module     = $params->{module} || 'test_module';
    my $branchcode = $params->{branchcode};

    reset_template( $params );

    my $letter = C4::Letters::GetPreparedLetter(
        module      => $module,
        letter_code => $code,
        branchcode  => '',
        tables      => $tables,
        substitute  => $substitute,
    );
    return $letter;
}
