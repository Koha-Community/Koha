# Copyright 2016 KohaSuomi
#
# This file is part of Koha.
#

use Modern::Perl;
use Test::More;
use Scalar::Util qw(blessed);
use Try::Tiny;

use C4::Letters;
use C4::BatchOverlay::Notifier;

use t::lib::TestContext;
use t::CataloguingCenter::ContextSysprefs;
use t::lib::TestObjects::ObjectFactory;
use t::lib::TestObjects::SystemPreferenceFactory;
use t::CataloguingCenter::Reports;


my $globalTestContext = {};
t::lib::TestContext::setUserenv({cardnumber => '1AbatchOverlay'}, $globalTestContext);
t::CataloguingCenter::ContextSysprefs::createBatchOverlayNotificationRules($globalTestContext);
t::lib::TestObjects::SystemPreferenceFactory->createTestGroup([
    {preference => 'staffClientBaseURL',
     value => 'localhost'},
    {preference => 'KohaAdminEmailAddress',
     value => 'koha@example.com'},
], undef, $globalTestContext);


subtest "Notification row for every subfield change", \&rowPerChange;
sub rowPerChange {
    my $testContext = {};
    my ($records, $r, $notifier, $changesByBib, $changes, $change, @biblionumbers, $bn, $bn0, $bn1, $messages, $letter);
    eval {

    my $reports = t::CataloguingCenter::Reports::createReports($testContext);

    $notifier = C4::BatchOverlay::Notifier->new();

    subtest "No blank notification letter sent", sub {
        $notifier->detectNotifiableFieldChanges($reports->[2]); #This report has no changes
        $notifier->queueTriggeredNotifications();
        $messages = C4::Letters::GetQueuedMessages({letter_code => 'BATCOVER'});
        is(@$messages, 0, "No blank messages queued needlessly");
    };

    subtest "Biblio 123456789-11", sub {
        $bn = $reports->[0]->getBiblionumber();

        $notifier->detectNotifiableFieldChanges($reports->[0]);
        $changesByBib = $notifier->getNotifiableChangesByBiblionumber();
        @biblionumbers = keys(%$changesByBib);
        is(@biblionumbers, 1, "Got changes for 1 different biblios");

        $changes = $changesByBib->{ $bn };
        is(@$changes, 3, "Got 3 notifiable changes in the first biblio");
        ok(blessed($changes->[0]) && $changes->[0]->isa('C4::Biblio::Diff::Change'), "Change is of correct type");
        is($changes->[0]->getFieldCode, '245', "Field");
        is($changes->[0]->getSubfieldCode, 'a', "Subfield");
        is($changes->[0]->getVal(0), 'I wish I met your mother', "Val old");
        is($changes->[0]->getVal(1), 'I wished I knew your mother', "Val new");
        is($changes->[0]->getVal(2), 'I wished I knew your mother', "Val merge");
        ok(blessed($changes->[1]) && $changes->[1]->isa('C4::Biblio::Diff::Change'), "Change is of correct type");
        is($changes->[1]->getFieldCode, '100', "Field");
        is($changes->[1]->getSubfieldCode, 'a', "Subfield");
        is($changes->[1]->getVal(0), 'Pertti Kurikka', "Val old");
        is($changes->[1]->getVal(1), 'Kurtti Perikka', "Val new");
        is($changes->[1]->getVal(2), 'Kurtti Perikka', "Val merge");
        ok(blessed($changes->[2]) && $changes->[2]->isa('C4::Biblio::Diff::Change'), "Change is of correct type");
        is($changes->[2]->getFieldCode, '020', "Field");
        is($changes->[2]->getSubfieldCode, 'a', "Subfield");
        is($changes->[2]->getVal(0), '123456789-10', "Val old");
        is($changes->[2]->getVal(1), '123456789-11', "Val new");
        is($changes->[2]->getVal(2), '123456789-11', "Val merge");
    };

    subtest "Biblio 123456789-21", sub {
        $bn = $reports->[1]->getBiblionumber();

        $notifier->detectNotifiableFieldChanges($reports->[1]);
        $changesByBib = $notifier->getNotifiableChangesByBiblionumber();
        @biblionumbers = keys(%$changesByBib);
        is(@biblionumbers, 2, "Accumulated changes for 2 different biblios");

        $changes = $changesByBib->{ $bn };
        is(@$changes, 2, "Got 2 notifiable changes in the second biblio");
        ok(blessed($changes->[0]) && $changes->[0]->isa('C4::Biblio::Diff::Change'), "Change is of correct type");
        is($changes->[0]->getFieldCode, '245', "Field");
        is($changes->[0]->getSubfieldCode, 'a', "Subfield");
        is($changes->[0]->getVal(0), 'Here we go again', "Val old");
        is($changes->[0]->getVal(1), 'Again go we here', "Val new");
        is($changes->[0]->getVal(2), 'Again go we here', "Val merge");
        ok(blessed($changes->[1]) && $changes->[1]->isa('C4::Biblio::Diff::Change'), "Change is of correct type");
        is($changes->[1]->getFieldCode, '020', "Field");
        is($changes->[1]->getSubfieldCode, 'a', "Subfield");
        is($changes->[1]->getVal(0), '123456789-20', "Val old");
        is($changes->[1]->getVal(1), '123456789-21', "Val new");
        is($changes->[1]->getVal(2), '123456789-21', "Val merge");
    };

    subtest "Make letters", sub {
        $bn0 = $reports->[0]->getBiblionumber();
        $bn1 = $reports->[1]->getBiblionumber();

        $letter = C4::BatchOverlay::Notifier::makeLetter( $notifier->getTriggeredNotificationsStash(), 'example@example.com', 'email', 'text/html; charset="UTF-8"' );

        is($letter->{title},            'BatchOverlay notification', "Letter title");
        is($letter->{code},             'BATCOVER', "Letter code");
        is($letter->{to_address},       'example@example.com', "Letter destination");
        is($letter->{message_transport_type}, 'email', "Letter mtt");
        is($letter->{'content-type'},   'text/html; charset="UTF-8"', "Letter content-type");
        is($letter->{content},<<LETTER, "Letter looks the same");
<p>
    For your convenience,<br/>
    BatchOverlay wishes to notify,<br/>
    that the following fields have been automatically changed:
</p>
<p>
    <a href='https://localhost/cgi-bin/koha/catalogue/detail.pl?biblionumber=$bn0'><h3>Biblio $bn0</h3></a>
    <table border=1 cellpadding=3>
        <tr>
            <td>245</td>
            <td>a</td>
            <td>I wish I met your mother</td>
            <td>I wished I knew your mother</td>
            <td>I wished I knew your mother</td>
        </tr>
        <tr>
            <td>100</td>
            <td>a</td>
            <td>Pertti Kurikka</td>
            <td>Kurtti Perikka</td>
            <td>Kurtti Perikka</td>
        </tr>
        <tr>
            <td>020</td>
            <td>a</td>
            <td>123456789-10</td>
            <td>123456789-11</td>
            <td>123456789-11</td>
        </tr>
    </table>
</p>
<p>
    <a href='https://localhost/cgi-bin/koha/catalogue/detail.pl?biblionumber=$bn1'><h3>Biblio $bn1</h3></a>
    <table border=1 cellpadding=3>
        <tr>
            <td>245</td>
            <td>a</td>
            <td>Here we go again</td>
            <td>Again go we here</td>
            <td>Again go we here</td>
        </tr>
        <tr>
            <td>020</td>
            <td>a</td>
            <td>123456789-20</td>
            <td>123456789-21</td>
            <td>123456789-21</td>
        </tr>
    </table>
</p>
<br/>
<p>
    Thank you for letting me serve you!<br/>
    <i>-Your friendly BatchOverlay-daemon</i>
</p>
<p>
P.S. You can change the notification settings from the BatchOverlay-system preference
</p>
LETTER
    };


    $notifier->queueTriggeredNotifications();


    subtest "Verify messages pushed to the message_queue", sub {
        $messages = C4::Letters::GetQueuedMessages({letter_code => 'BATCOVER'});
        $bn = $reports->[0]->getBiblionumber();
        ok($messages->[0]->{content} =~ /$bn/,  "1st Biblionumber found");
        $bn = $reports->[1]->getBiblionumber();
        ok($messages->[0]->{content} =~ /$bn/,  "2nd Biblionumber found");

        #Some smoke tests
        ok($messages->[0]->{content} =~ /100/, "Field 100a");
        ok($messages->[0]->{content} =~ /245/, "Field 245a");
        ok($messages->[0]->{content} =~ /020/, "Field 020a");

        #Did we get the correct send and receival addresses?
        is($messages->[0]->{from_address},
           C4::Context->preference('KohaAdminEmailAddress'),
           "From address");
        is($messages->[0]->{to_address},
           'koha@example.com',
           "To address");
        is($messages->[0]->{content_type},
           'text/html; charset="UTF-8"',
           "Content-type is html");
        is($messages->[0]->{status},
           'pending',
           "Status is pending");
    };


    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
}

t::lib::TestObjects::ObjectFactory->tearDownTestContext($globalTestContext);
done_testing();
