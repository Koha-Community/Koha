--
-- Default sample notices for Koha.
--
-- Copyright (C) 2011 Magnus Enger Libriotech
--
-- This file is part of Koha.
--
-- Koha is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
--
-- Koha is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Koha; if not, see <http://www.gnu.org/licenses>.


INSERT INTO letter (module, code, name, title, content, message_transport_type)
VALUES ('circulation','ODUE','Purring','Purring på dokument','<<borrowers.firstname>> <<borrowers.surname>>,\n\nDu har lån som skulle vært levert. Biblioteket krever ikke inn gebyrer, men vennligst lever eller forny lånet/lånene ved biblioteket.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nTelefon: <<branches.branchphone>>\nFax: <<branches.branchfax>>\nE-post: <<branches.branchemail>>\n\nDersom du har et passord og lånet/lånene kan fornyes kan du gjøre dette på nettet. Dersom du overskrider lånetiden med mer enn 30 dager vil lånekortet bli sperret.\n\nFølgende lån har gått over tiden:\n\n<item>"<<biblio.title>>" av <<biblio.author>>, <<items.itemcallnumber>>, Strekkode: <<items.barcode>> Gebyr: <<items.fine>></item>\n\nPå forhånd takk.\n\n<<branches.branchname>>\n', 'email'),
('claimacquisition','ACQCLAIM','Periodikapurring','Eksemplar ikke mottatt','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\n<order>Bestillingsnummer <<aqorders.ordernumber>> (<<aqorders.title>>) (<<aqorders.quantity>> ordered) ($<<aqorders.listprice>> each) har ikke blitt mottatt.</order>', 'email'),
('orderacquisition','ACQORDER','Acquisition order','Order','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\nPlease order for the library:\r\n\r\n<order>Ordernumber <<aqorders.ordernumber>> (<<biblio.title>>) (quantity: <<aqorders.quantity>>) ($<<aqorders.listprice>> each).</order>\r\n\r\nThank you,\n\n<<branches.branchname>>', 'email'),
('serial','SERIAL_ALERT','Sirkulasjon','Et dokument er nå tilgjengelig','<<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nDette dokumentet er tilgjengelig:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)\r\n\r\nVennligst kom og hent det når det passer.', 'email'),
('members','ACCTDETAILS','Mal for kontodetaljer - STANDARD','Dine nye kontodetaljer i Koha.','Hei <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\nDine nye detaljer er:\r\n\r\nBruker:  <<borrowers.userid>>\r\nPassord: <<borrowers.password>>\r\n\r\nDersom det oppstår problemer, vennligst kontakt biblioteket.\r\n\r\nVennlig hilsen,\r\nBiblioteket\r\nkohaadmin@yoursite.org', 'email'),
('circulation','DUE','Innleveringspåminnelse','Innleveringspåminnelse','<<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nDette dokumentet må nå leveres:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)', 'email'),
('circulation','DUEDGST','Innleveringspåminnelse (sammendrag)','Innleveringspåminnelse','Du har <<count>> dokumenter som skulle vært levert.', 'email'),
('circulation','PREDUE','Forhåndspåminnelse','Forhåndspåminnelse','<<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nDette dokumentet må snart leveres:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)', 'email'),
('circulation','PREDUEDGST','Forhåndspåminnelse (sammendrag)','Forhåndspåminnelse','Du har lånt <<count>> dokumenter som snart må leveres.', 'email'),
('circulation','RENEWAL','Fornying','Fornyinger','Følgende lån har blitt fornyet:\r\n----\r\n<<biblio.title>>\r\n----\r\n', 'email'),
('reserves', 'HOLD', 'Hentemelding', 'Hentemelding fra <<branches.branchname>>', '<<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nEt reservert dokument er klart til henting fra <<reserves.waitingdate>>:\r\n\r\nTittel: <<biblio.title>>\r\nForfatter: <<biblio.author>>\r\nEksemplar: <<items.copynumber>>\r\nHentested: <<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress3>>\r\n<<branches.branchcity>> <<branches.branchzip>>', 'email'),
('reserves', 'HOLD', 'Hentemelding', 'Hentemelding', '<<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>>\r\n<<borrowers.address>>\r\n<<borrowers.city>> <<borrowers.zipcode>>\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>> <<borrowers.cardnumber>>\r\n\r\nDu har et reservert dokument som kan hentes fra  <<reserves.waitingdate>>:\r\n\r\nTittel: <<biblio.title>>\r\nForfatter: <<biblio.author>>\r\nEksemplar: <<items.copynumber>>\r\n', 'print'),
('circulation','CHECKIN','Innlevering','Melding om innlevering','Følgende dokument har blitt innlevert:\r\n----\r\n[% biblio.title %]\r\n----\r\nVennlig hilsen\r\nBiblioteket', 'email'),
('circulation','CHECKOUT','Utlån','Melding om utlån','Følgende dokument har blitt lånt ut:\r\n----\r\n[% biblio.title %]\r\n----\r\nVennlig hilsen\r\nBiblioteket', 'email'),
('reserves', 'HOLDPLACED', 'Melding om reservasjon', 'Melding om reservasjon','Følgende dokument har blitt reservert : <<biblio.title>> (<<biblio.biblionumber>>) av <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>).', 'email'),
('reserves','HOLD_REMINDER','','Waiting hold reminder',0,'You have waiting holds.','Dear [% borrower.firstname %] [% borrower.surname %],\r\n\r\nThe following holds are waiting at [% branch.branchname %]:\r\n\\r\n[% FOREACH hold IN holds %]\r\n    [% hold.biblio.title %] : waiting since [% hold.waitingdate | $KohaDates %]\r\n[% END %]','email'),
('reserves', 'CANCEL_HOLD_ON_LOST', 'Hold has been cancelled', "Hold has been cancelled", "Dear [% borrower.firstname %] [% borrower.surname %],\n\nWe regret to inform you, that the following item can not be provided due to it being missing. Your hold was cancelled.\n\nTitle: [% biblio.title %]\nAuthor: [% biblio.author %]\nCopy: [% item.copynumber %]\nLocation: [% branch.branchname %]", 'email'),
('suggestions','ACCEPTED','Forslag godtatt', 'Innkjøpsforslag godtatt','<<borrowers.firstname>> <<borrowers.surname>>,\n\nDu har foreslått at biblioteket kjøper inn <<suggestions.title>> av <<suggestions.author>>.\n\nBiblioteket har vurdert forslaget i dag. Dokumentet vil bli bestilt så fort det lar seg gjøre. Du vil få en ny melding når bestillingen er gjort, og når dokumentet ankommer biblioteket.\n\nEr det noe du lurer på, vennligst kontakt oss på <<branches.branchemail>>.\n\nVennlig hilsen,\n\n<<branches.branchname>>', 'email'),
('suggestions','AVAILABLE','Foreslått dokument tilgjengelig', 'Foreslått dokument tilgjengelig','<<borrowers.firstname>> <<borrowers.surname>>,\n\nDu har foreslått at biblioteket kjøper inn <<suggestions.title>> av <<suggestions.author>>.\n\nVi har gleden av å informere deg om at dokumentet nå er innlemmet i samlingen.\n\nEr det noe du lurer på, vennligst kontakt oss på <<branches.branchemail>>.\n\nVennlig hilsen,\n\n<<branches.branchname>>', 'email'),
('suggestions','ORDERED','Innkjøpsforslag i bestilling', 'Innkjøpsforslag i bestilling','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nDu har foreslått at biblioteket kjøper inn <<suggestions.title>> av <<suggestions.author>>.\n\nVi har gleden av å informere deg om at dokumentet du foreslo nå er i bestilling.\n\nDu vil få en ny melding når dokumentet er tilgjengelig.\n\nEr det noe du lurer på, vennligst kontakt oss på <<branches.branchemail>>.\n\nVennlig hilsen,\n\n<<branches.branchname>>', 'email'),
('suggestions','REJECTED','Innkjøpsforslag avslått', 'Innkjøpsforslag avslått','<<borrowers.firstname>> <<borrowers.surname>>,\n\nDu har foreslått at biblioteket kjøper inn <<suggestions.title>> av <<suggestions.author>>.\n\nBiblioteket har vurdert innkjøpsforslaget ditt i dag, og bestemt seg for å ikke ta det til følge.\n\nBegrunnelse: <<suggestions.reason>>\n\nEr det noe du lurer på, vennligst kontakt oss på <<branches.branchemail>>.\n\nVennlig hilsen,\n\n<<branches.branchname>>', 'email'),
('suggestions','TO_PROCESS','Notify fund owner', 'A suggestion is ready to be processed','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nA new suggestion is ready to be processed: <<suggestions.title>> by <<suggestions.author>>.\n\nThank you,\n\n<<branches.branchname>>', 'email'),
('suggestions', 'NOTIFY_MANAGER', 'Notify manager of a suggestion', "A suggestion has been assigned to you", "Dear [% borrower.firstname %] [% borrower.surname %],\nA suggestion has been assigned to you: [% suggestion.title %].\nThank you,\n[% branch.branchname %]", 'email'),
('members', 'DISCHARGE', 'Discharge', 'Discharge for <<borrowers.firstname>> <<borrowers.surname>>', '<h1>Discharge</h1>\r\n\r\nThe library <<borrowers.branchcode>> certifies that the following borrower :\r\n\r\n    <<borrowers.firstname>> <<borrowers.surname>>\r\n   Cardnumber : <<borrowers.cardnumber>>\r\n\r\nreturned all his documents.', 'email'),
('members', 'PROBLEM_REPORT','OPAC problem report','OPAC problem report','Username: <<problem_reports.username>>\n\nProblem page: <<problem_reports.problempage>>\n\nTitle: <<problem_reports.title>>\n\nMessage: <<problem_reports.content>>','email');

INSERT INTO `letter` (module, code, name, title, content, is_html, message_transport_type)
VALUES ('suggestions','NEW_SUGGESTION','New suggestion','New suggestion','<h3>Suggestion pendin    g approval</h3>
    <p><h4>Suggested by</h4>
    <ul>
    <li><<borrowers.firstname>> <<borrowers.surname>></li>
    <li><<borrowers.cardnumber>></li>
    <li><<borrowers.phone>></li>
    <li><<borrowers.email>></li>
    </ul>
    </p>
    <p><h4>Title suggested</h4>
    <ul>
    <li><b>Library:</b> <<branches.branchname>></li>
    <li><b>Title:</b> <<suggestions.title>></li>
    <li><b>Author:</b> <<suggestions.author>></li>
    <li><b>Copyright date:</b> <<suggestions.copyrightdate>></li>
    <li><b>Standard number (ISBN, ISSN or other):</b> <<suggestions.isbn>></li>
    <li><b>Publisher:</b> <<suggestions.publishercode>></li>
    <li><b>Collection title:</b> <<suggestions.collectiontitle>></li>
    <li><b>Publication place:</b> <<suggestions.place>></li>
    <li><b>Quantity:</b> <<suggestions.quantity>></li>
    <li><b>Item type:</b>  <<suggestions.itemtype>></li>
    <li><b>Reason for suggestion:</b> <<suggestions.patronreason>></li>
    <li><b>Notes:</b> <<suggestions.note>></li>
    </ul>
    </p>',1, 'email'),
    ('circulation','CHECKINSLIP','Checkin slip','Checkin slip',
"<h3>[% branch.branchname %]</h3>
Checked in items for [% borrower.title %] [% borrower.firstname %] [% borrower.initials %] [% borrower.surname %] <br />
([% borrower.cardnumber %]) <br />

[% today | $KohaDates %]<br />

<h4>Checked in today</h4>
[% FOREACH checkin IN old_checkouts %]
[% SET item = checkin.item %]
<p>
[% item.biblio.title %] <br />
Barcode: [% item.barcode %] <br />
</p>
[% END %]", 1, 'print');

INSERT INTO `letter` (module, code, name, title, content, is_html)
VALUES ('circulation','ISSUESLIP','Utlån','Utlån', '<h3><<branches.branchname>></h3>
Utlånt til <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(<<borrowers.cardnumber>>) <br />

<<today>><br />

<h4>Utlånt</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Strekkode: <<items.barcode>><br />
Innleveringsfrist: <<issues.date_due>><br />
</p>
</checkedout>

<h4>Forfalte lån</h4>
<overdue>
<p>
<<biblio.title>> <br />
Strekkode: <<items.barcode>><br />
Innleveringsfrist: <<issues.date_due>><br />
</p>
</overdue>

<hr>

<h4 style="text-align: center; font-style:italic;">Nyheter</h4>
<news>
<div class="newsitem">
<h5 style="margin-bottom: 1px; margin-top: 1px"><b><<opac_news.title>></b></h5>
<p style="margin-bottom: 1px; margin-top: 1px"><<opac_news.content>></p>
<p class="newsfooter" style="font-size: 8pt; font-style:italic; margin-bottom: 1px; margin-top: 1px">Publisert <<opac_news.published_on>></p>
<hr />
</div>
</news>', 1),
('circulation','ISSUEQSLIP','Utlån (enkel)','Utlån (enkel)', '<h3><<branches.branchname>></h3>
Utlånt til <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(<<borrowers.cardnumber>>) <br />

<<today>><br />

<h4>Utlånt i dag</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Strekkode: <<items.barcode>><br />
Innleveringsfrist: <<issues.date_due>><br />
</p>
</checkedout>', 1),
('circulation','HOLD_SLIP','Reservasjon','Reservasjon', '<h5>Dato: <<today>></h5>

<h3> Overfør til/Reservasjon hos <<branches.branchname>></h3>

<h3><<borrowers.surname>>, <<borrowers.firstname>></h3>

<ul>
    <li><<borrowers.cardnumber>></li>
    <li><<borrowers.phone>></li>
    <li> <<borrowers.address>><br />
         <<borrowers.address2>><br />
         <<borrowers.city >>  <<borrowers.zipcode>>
    </li>
    <li><<borrowers.email>></li>
</ul>
<br />
<h3>RESERVERT</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
   <li><<reserves.waitingdate>></li>
</ul>
<p>Kommentarer:
<pre><<reserves.reservenotes>></pre>
</p>
', 1),
('circulation','TRANSFERSLIP','Overføringslapp','Overføringslapp', '<h5>Dato: <<today>></h5>

<h3>Overføres til <<branches.branchname>></h3>

<h3>EKSEMPLAR</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
</ul>', 1);

INSERT INTO `letter` (`module`,`code`,`branchcode`,`name`,`is_html`,`title`,`content`)
VALUES (
'members',  'OPAC_REG_VERIFY',  '',  'Verifikasjon av egenregistrering i publikumskatalogen',  '1',  'Verifiser registreringen din',  'Hei!

D har blitt registrert som bruker av biblioteket. Verifiser epostadressen din ved å klikke på lenka nedenfor:

<<OPACBaseURL>>/cgi-bin/koha/opac-registration-verify.pl?token=<<borrower_modifications.verification_token>>

Dersom du ikke har bedt om å bli registret som bruker av biblioteket kan du se bort fra denne engangsmeldingen. Forespørselen vil snart gå ut på dato.'
);

INSERT INTO  letter (module, code, branchcode, name, is_html, title, content)
VALUES ('members', 'SHARE_INVITE', '', 'Invitation for sharing a list', '0', 'Share list <<listname>>', 'Dear patron,

One of our patrons, <<borrowers.firstname>> <<borrowers.surname>>, invites you to share a list <<listname>> in our library catalog.

To access this shared list, please click on the following URL or copy-and-paste it into your browser address bar.

<<shareurl>>

In case you are not a patron in our library or do not want to accept this invitation, please ignore this mail. Note also that this invitation expires within two weeks.

Thank you.

Your library.'
);
INSERT INTO  letter (module, code, branchcode, name, is_html, title, content)
VALUES ( 'members', 'SHARE_ACCEPT', '', 'Notification about an accepted share', '0', 'Share on list <<listname>> accepted', 'Dear patron,

We want to inform you that <<borrowers.firstname>> <<borrowers.surname>> accepted your invitation to share your list <<listname>> in our library catalog.

Thank you.

Your library.'
);

INSERT INTO letter(module, code, branchcode, name, title, content, message_transport_type)
VALUES ('acquisition', 'ACQ_NOTIF_ON_RECEIV', '', 'Notification on receiving', 'Order received', 'Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\n The order <<aqorders.ordernumber>> (<<biblio.title>>) has been received.\n\nYour library.', 'email'),
('members','MEMBERSHIP_EXPIRY','','Account expiration','Account expiration','Dear <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>,.\r\n\r\nYour library card will expire soon, on:\r\n\r\n<<borrowers.dateexpiry>>\r\n\r\nThank you,\r\n\r\nLibrarian\r\n\r\n<<branches.branchname>>','email');

INSERT INTO letter ( module, code, branchcode, name, is_html, title, content, message_transport_type )
VALUES ( 'circulation', 'OVERDUES_SLIP', '', 'Overdues slip', '0', 'Overdues slip', 'The following item(s) is/are currently overdue:

<item>"<<biblio.title>>" by <<biblio.author>>, <<items.itemcallnumber>>, Barcode: <<items.barcode>> Fine: <<items.fine>></item>
', 'print' );

INSERT INTO `letter` (module, code, branchcode, name, is_html, title, content, message_transport_type)
VALUES ('members','PASSWORD_RESET','','Online password reset',1,'Koha password recovery','<html>\r\n<p>This email has been sent in response to your password recovery request for the account <strong><<user>></strong>.\r\n</p>\r\n<p>\r\nYou can now create your new password using the following link:\r\n<br/><a href=\"<<passwordreseturl>>\"><<passwordreseturl>></a>\r\n</p>\r\n<p>This link will be valid for 2 days from this email\'s reception, then you must reapply if you do not change your password.</p>\r\n<p>Thank you.</p>\r\n</html>\r\n','email'
);

INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
('circulation', 'AR_CANCELED', '', 'Article request - canceled', 0, 'Article request canceled', 'Dear <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>),\r\n\r\nYour request for an article from <<biblio.title>> (<<items.barcode>>) has been canceled for the following reason:\r\n\r\n<<article_requests.notes>>\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n\r\nYour library', 'email'),
('circulation', 'AR_COMPLETED', '', 'Article request - completed', 0, 'Article request completed', 'Dear <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>),\r\n\r\nWe have completed your request for an article from <<biblio.title>> (<<items.barcode>>).\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n\r\nYou may pick your article up at <<branches.branchname>>.\r\n\r\nThank you!', 'email'),
('circulation', 'AR_PENDING', '', 'Article request - pending', 0, 'Article request received', 'Dear <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nWe have received your request for an article from <<biblio.title>> (<<items.barcode>>).\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n\r\n\r\nThank you!', 'email'),
('circulation', 'AR_SLIP', '', 'Article request - print slip', 0, 'Article request', 'Article request:\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>),\r\n\r\nTitle: <<biblio.title>>\r\nBarcode: <<items.barcode>>\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n', 'print'),
('circulation', 'AR_PROCESSING', '', 'Article request - processing', 0, 'Article request processing', 'Dear <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>),\r\n\r\nWe are now processing your request for an article from <<biblio.title>> (<<items.barcode>>).\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n\r\nThank you!', 'email'),
('circulation', 'CHECKOUT_NOTE', '', 'Checkout note on item set by patron', '0', 'Checkout note', '<<borrowers.firstname>> <<borrowers.surname>> has added a note to the item <<biblio.title>> - <<biblio.author>> (<<biblio.biblionumber>>).','email');

INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`, `lang`) VALUES
('circulation', 'ACCOUNT_PAYMENT', '', 'Account payment', 0, 'Account payment', '[%- USE Price -%]\r\nA payment of [% credit.amount * -1 | $Price %] has been applied to your account.\r\n\r\nThis payment affected the following fees:\r\n[%- FOREACH o IN offsets %]\r\nDescription: [% o.debit.description %]\r\nAmount paid: [% o.amount * -1 | $Price %]\r\nAmount remaining: [% o.debit.amountoutstanding | $Price %]\r\n[% END %]', 'email', 'default'),
('circulation', 'ACCOUNT_WRITEOFF', '', 'Account writeoff', 0, 'Account writeoff', '[%- USE Price -%]\r\nAn account writeoff of [% credit.amount * -1 | $Price %] has been applied to your account.\r\n\r\nThis writeoff affected the following fees:\r\n[%- FOREACH o IN offsets %]\r\nDescription: [% o.debit.description %]\r\nAmount paid: [% o.amount * -1 | $Price %]\r\nAmount remaining: [% o.debit.amountoutstanding | $Price %]\r\n[% END %]', 'email', 'default');

INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`, `lang`) VALUES
('circulation', 'ACCOUNT_CREDIT', '', 'Account payment', 0, 'Account payment', '<table>
[% IF ( LibraryName ) %]
 <tr>
    <th colspan="4" class="centerednames">
        <h3>[% LibraryName | html %]</h3>
    </th>
 </tr>
[% END %]
 <tr>
    <th colspan="4" class="centerednames">
        <h2><u>Fee receipt</u></h2>
    </th>
 </tr>
 <tr>
    <th colspan="4" class="centerednames">
        <h2>[% Branches.GetName( patron.branchcode ) | html %]</h2>
    </th>
 </tr>
 <tr>
    <th colspan="4">
        Received with thanks from  [% patron.firstname | html %] [% patron.surname | html %] <br />
        Card number: [% patron.cardnumber | html %]<br />
    </th>
 </tr>
  <tr>
    <th>Date</th>
    <th>Description of charges</th>
    <th>Note</th>
    <th>Amount</th>
 </tr>

  [% FOREACH account IN accounts %]
    <tr class="highlight">
      <td>[% account.date | $KohaDates %]</td>
      <td>
        [% PROCESS account_type_description account=account %]
        [%- IF account.description %], [% account.description | html %][% END %]
      </td>
      <td>[% account.note | html %]</td>
      [% IF ( account.amountcredit ) %]<td class="credit">[% ELSE %]<td class="debit">[% END %][% account.amount | $Price %]</td>
    </tr>

  [% END %]
<tfoot>
  <tr>
    <td colspan="3">Total outstanding dues as on date: </td>
    [% IF ( totalcredit ) %]<td class="credit">[% ELSE %]<td class="debit">[% END %][% total | $Price %]</td>
  </tr>
</tfoot>
</table>', 'print', 'default');

INSERT IGNORE INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`, `lang`) VALUES
('circulation', 'ACCOUNT_DEBIT', '', 'Account fee', 0, 'Account fee', '<table>
  [% IF ( LibraryName ) %]
    <tr>
      <th colspan="5" class="centerednames">
        <h3>[% LibraryName | html %]</h3>
      </th>
    </tr>
  [% END %]

  <tr>
    <th colspan="5" class="centerednames">
      <h2><u>INVOICE</u></h2>
    </th>
  </tr>
  <tr>
    <th colspan="5" class="centerednames">
      <h2>[% Branches.GetName( patron.branchcode ) | html %]</h2>
    </th>
  </tr>
  <tr>
    <th colspan="5" >
      Bill to: [% patron.firstname | html %] [% patron.surname | html %] <br />
      Card number: [% patron.cardnumber | html %]<br />
    </th>
  </tr>
  <tr>
    <th>Date</th>
    <th>Description of charges</th>
    <th>Note</th>
    <th style="text-align:right;">Amount</th>
    <th style="text-align:right;">Amount outstanding</th>
  </tr>

  [% FOREACH account IN accounts %]
    <tr class="highlight">
      <td>[% account.date | $KohaDates%]</td>
      <td>
        [% PROCESS account_type_description account=account %]
        [%- IF account.description %], [% account.description | html %][% END %]
      </td>
      <td>[% account.note | html %]</td>
      [% IF ( account.amountcredit ) %]<td class="credit">[% ELSE %]<td class="debit">[% END %][% account.amount | $Price %]</td>
      [% IF ( account.amountoutstandingcredit ) %]<td class="credit">[% ELSE %]<td class="debit">[% END %][% account.amountoutstanding | $Price %]</td>
    </tr>
  [% END %]

  <tfoot>
    <tr>
      <td colspan="4">Total outstanding dues as on date: </td>
      [% IF ( totalcredit ) %]<td class="credit">[% ELSE %]<td class="debit">[% END %][% total | $Price %]</td>
    </tr>
  </tfoot>
</table>', 'print', 'default');

INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
('circulation', 'SR_SLIP', '', 'Stock rotation slip', 0, 'Stock rotation report', 'Stock rotation report for [% branch.name %]:\r\n\r\n[% IF branch.items.size %][% branch.items.size %] items to be processed for this branch.\r\n[% ELSE %]No items to be processed for this branch\r\n[% END %][% FOREACH item IN branch.items %][% IF item.reason != \'in-demand\' %]Title: [% item.title %]\r\nAuthor: [% item.author %]\r\nCallnumber: [% item.callnumber %]\r\nLocation: [% item.location %]\r\nBarcode: [% item.barcode %]\r\nOn loan?: [% item.onloan %]\r\nStatus: [% item.reason %]\r\nCurrent library: [% item.branch.branchname %] [% item.branch.branchcode %]\r\n\r\n[% END %][% END %]', 'email');
INSERT IGNORE INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`, `lang`) VALUES
('pos', 'RECEIPT', '', 'Point of sale receipt', 0, 'Receipt', '[% PROCESS "accounts.inc" %]
<table>
[% IF ( LibraryName ) %]
 <tr>
    <th colspan="2" class="centerednames">
        <h3>[% LibraryName | html %]</h3>
    </th>
 </tr>
[% END %]
 <tr>
    <th colspan="2" class="centerednames">
        <h2>[% Branches.GetName( payment.branchcode ) | html %]</h2>
    </th>
 </tr>
<tr>
    <th colspan="2" class="centerednames">
        <h3>[% payment.date | $KohaDates %]</h3>
</tr>
<tr>
  <td>Transaction ID: </td>
  <td>[% payment.accountlines_id %]</td>
</tr>
<tr>
  <td>Operator ID: </td>
  <td>[% payment.manager_id %]</td>
</tr>
<tr>
  <td>Payment type: </td>
  <td>[% payment.payment_type %]</td>
</tr>
 <tr></tr>
 <tr>
    <th colspan="2" class="centerednames">
        <h2><u>Fee receipt</u></h2>
    </th>
 </tr>
 <tr></tr>
 <tr>
    <th>Description of charges</th>
    <th>Amount</th>
  </tr>

  [% FOREACH offset IN offsets %]
    <tr>
        <td>[% PROCESS account_type_description account=offset.debit %]</td>
        <td>[% offset.amount * -1 | $Price %]</td>
    </tr>
  [% END %]

<tfoot>
  <tr class="highlight">
    <td>Total: </td>
    <td>[% payment.amount * -1| $Price %]</td>
  </tr>
  <tr>
    <td>Tendered: </td>
    <td>[% collected | $Price %]</td>
  </tr>
  <tr>
    <td>Change: </td>
    <td>[% change | $Price %]</td>
    </tr>
</tfoot>
</table>', 'print', 'default');

INSERT INTO letter (module, code, name, title, content, message_transport_type) VALUES ('circulation', 'AUTO_RENEWALS', 'Notification of automatic renewal', 'Automatic renewal notice',
"Dear [% borrower.firstname %] [% borrower.surname %],
[% IF checkout.auto_renew_error %]
The following item, [% biblio.title %], has not been renewed because:
[% IF checkout.auto_renew_error == 'too_many' %]
You have reached the maximum number of checkouts possible.
[% ELSIF checkout.auto_renew_error == 'on_reserve' %]
This item is on hold for another patron.
[% ELSIF checkout.auto_renew_error == 'restriction' %]
You are currently restricted.
[% ELSIF checkout.auto_renew_error == 'overdue' %]
You have overdue items.
[% ELSIF checkout.auto_renew_error == 'auto_too_late' %]
It\'s too late to renew this item.
[% ELSIF checkout.auto_renew_error == 'auto_too_much_oweing' %]
Your total unpaid fines are too high.
[% ELSIF checkout.auto_renew_error == 'too_unseen' %]
This item must be renewed at the library.
[% END %]
[% ELSE %]
The following item, [% biblio.title %], has correctly been renewed and is now due on [% checkout.date_due | $KohaDates as_due_date => 1 %]
[% END %]", 'email');

INSERT IGNORE INTO letter(module, code, branchcode, name, is_html, title, content, message_transport_type, lang) VALUES ('ill', 'ILL_PICKUP_READY', '', 'ILL request ready for pickup', 0, "Interlibrary loan request ready for pickup", "Dear [% borrower.firstname %] [% borrower.surname %],\n\nThe Interlibrary loans request number [% illrequest.illrequest_id %] you placed for:\n\n- [% ill_bib_title %] - [% ill_bib_author %]\n\nis ready for pick up from [% branch.branchname %].\n\nKind Regards\n\n[% branch.branchname %]\n[% branch.branchaddress1 %]\n[% branch.branchaddress2 %]\n[% branch.branchaddress3 %]\n[% branch.branchcity %]\n[% branch.branchstate %]\n[% branch.branchzip %]\n[% branch.branchphone %]\n[% branch.branchillemail %]\n[% branch.branchemail %]", 'email', 'default');
INSERT IGNORE INTO letter(module, code, branchcode, name, is_html, title, content, message_transport_type, lang) VALUES ('ill', 'ILL_REQUEST_UNAVAIL', '', 'ILL request unavailable', 0, "Interlibrary loan request unavailable", "Dear [% borrower.firstname %] [% borrower.surname %],\n\nThe Interlibrary loans request number [% illrequest.illrequest_id %] you placed for\n\n- [% ill_bib_title %] - [% ill_bib_author %]\n\nis unfortunately unavailable.\n\nKind Regards\n\n[% branch.branchname %]\n[% branch.branchaddress1 %]\n[% branch.branchaddress2 %]\n[% branch.branchaddress3 %]\n[% branch.branchcity %]\n[% branch.branchstate %]\n[% branch.branchzip %]\n[% branch.branchphone %]\n[% branch.branchillemail %]\n[% branch.branchemail %]", 'email', 'default');
INSERT IGNORE INTO letter(module, code, branchcode, name, is_html, title, content, message_transport_type, lang) VALUES ('ill', 'ILL_REQUEST_CANCEL', '', 'ILL request cancelled', 0, "Interlibrary loan request cancelled", "The patron for interlibrary loans request [% illrequest.illrequest_id %], with the following details, has requested cancellation of this ILL request:\n\n[% ill_full_metadata %]", 'email', 'default');
INSERT IGNORE INTO letter(module, code, branchcode, name, is_html, title, content, message_transport_type, lang) VALUES ('ill', 'ILL_REQUEST_MODIFIED', '', 'ILL request modified', 0, "Interlibrary loan request modified", "The patron for interlibrary loans request [% illrequest.illrequest_id %], with the following details, has modified this ILL request:\n\n[% ill_full_metadata %]", 'email', 'default');
INSERT IGNORE INTO letter(module, code, branchcode, name, is_html, title, content, message_transport_type, lang) VALUES ('ill', 'ILL_PARTNER_REQ', '', 'ILL request to partners', 0, "Interlibrary loan request to partners", "Dear Sir/Madam,\n\nWe would like to request an interlibrary loan for a title matching the following description:\n\n[% ill_full_metadata %]\n\nPlease let us know if you are able to supply this to us.\n\nKind Regards\n\n[% branch.branchname %]\n[% branch.branchaddress1 %]\n[% branch.branchaddress2 %]\n[% branch.branchaddress3 %]\n[% branch.branchcity %]\n[% branch.branchstate %]\n[% branch.branchzip %]\n[% branch.branchphone %]\n[% branch.branchillemail %]\n[% branch.branchemail %]", 'email', 'default');
INSERT IGNORE INTO letter(module, code, branchcode, name, is_html, title, content, message_transport_type, lang) VALUES ('ill', 'ILL_PICKUP_READY', '', 'ILL request ready for pickup', 0, "Interlibrary loan request ready for pickup", "Dear [% borrower.firstname %] [% borrower.surname %],\n\nThe Interlibrary loans request number [% illrequest.illrequest_id %] you placed for:\n\n- [% ill_bib_title %] - [% ill_bib_author %]\n\nis ready for pick up from [% branch.branchname %].\n\nKind Regards\n\n[% branch.branchname %]\n[% branch.branchaddress1 %]\n[% branch.branchaddress2 %]\n[% branch.branchaddress3 %]\n[% branch.branchcity %]\n[% branch.branchstate %]\n[% branch.branchzip %]\n[% branch.branchphone %]\n[% branch.branchillemail %]\n[% branch.branchemail %]", 'sms', 'default');
INSERT IGNORE INTO letter(module, code, branchcode, name, is_html, title, content, message_transport_type, lang) VALUES ('ill', 'ILL_REQUEST_UNAVAIL', '', 'ILL request unavailable', 0, "Interlibrary loan request unavailable", "Dear [% borrower.firstname %] [% borrower.surname %],\n\nThe Interlibrary loans request number [% illrequest.illrequest_id %] you placed for\n\n- [% ill_bib_title %] - [% ill_bib_author %]\n\nis unfortunately unavailable.\n\nKind Regards\n\n[% branch.branchname %]\n[% branch.branchaddress1 %]\n[% branch.branchaddress2 %]\n[% branch.branchaddress3 %]\n[% branch.branchcity %]\n[% branch.branchstate %]\n[% branch.branchzip %]\n[% branch.branchphone %]\n[% branch.branchillemail %]\n[% branch.branchemail %]", 'sms', 'default');
INSERT IGNORE INTO letter(module, code, branchcode, name, is_html, title, content, message_transport_type, lang) VALUES ('ill', 'ILL_REQUEST_CANCEL', '', 'ILL request cancelled', 0, "Interlibrary loan request cancelled", "The patron for interlibrary loans request [% illrequest.illrequest_id %], with the following details, has requested cancellation of this ILL request:\n\n[% ill_full_metadata %]", 'sms', 'default');
INSERT IGNORE INTO letter(module, code, branchcode, name, is_html, title, content, message_transport_type, lang) VALUES ('ill', 'ILL_REQUEST_MODIFIED', '', 'ILL request modified', 0, "Interlibrary loan request modified", "The patron for interlibrary loans request [% illrequest.illrequest_id %], with the following details, has modified this ILL request:\n\n[% ill_full_metadata %]", 'sms', 'default');
INSERT IGNORE INTO letter(module, code, branchcode, name, is_html, title, content, message_transport_type, lang) VALUES ('ill', 'ILL_PARTNER_REQ', '', 'ILL request to partners', 0, "Interlibrary loan request to partners", "Dear Sir/Madam,\n\nWe would like to request an interlibrary loan for a title matching the following description:\n\n[% ill_full_metadata %]\n\nPlease let us know if you are able to supply this to us.\n\nKind Regards\n\n[% branch.branchname %]\n[% branch.branchaddress1 %]\n[% branch.branchaddress2 %]\n[% branch.branchaddress3 %]\n[% branch.branchcity %]\n[% branch.branchstate %]\n[% branch.branchzip %]\n[% branch.branchphone %]\n[% branch.branchillemail %]\n[% branch.branchemail %]", 'sms', 'default');

INSERT IGNORE INTO letter (module, code, name, title, content, message_transport_type) VALUES ('circulation', 'AUTO_RENEWALS_DGST', 'Notification on auto renewals', 'Auto renewals (Digest)',
"Dear [% borrower.firstname %] [% borrower.surname %],
[% IF error %]
    There were [% error %] items that were not renewed.
[% END %]
[% IF success %]
    There were [% success %] items that were renewed.
[% END %]
[% FOREACH checkout IN checkouts %]
    [% checkout.item.biblio.title %] : [% checkout.item.barcode %]
    [% IF !checkout.auto_renew_error %]
        was renewed until [% checkout.date_due | $KohaDates as_due_date => 1%]
    [% ELSIF checkout.auto_renew_error == 'too_many' %]
        You have reached the maximum number of checkouts possible.
    [% ELSIF checkout.auto_renew_error == 'on_reserve' %]
        This item is on hold for another patron.
    [% ELSIF checkout.auto_renew_error == 'restriction' %]
        You are currently restricted.
    [% ELSIF checkout.auto_renew_error == 'overdue' %]
        You have overdue items.
    [% ELSIF checkout.auto_renew_error == 'auto_too_late' %]
        It's too late to renew this item.
    [% ELSIF checkout.auto_renew_error == 'auto_too_much_oweing' %]
        Your total unpaid fines are too high.
    [% ELSIF checkout.auto_renew_error == 'too_unseen' %]
        This item must be renewed at the library.
    [% END %]
[% END %]
", 'email');
