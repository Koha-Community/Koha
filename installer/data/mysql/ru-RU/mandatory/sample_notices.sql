INSERT INTO `letter` (module, code, name, title, content, message_transport_type)
VALUES ('circulation','ODUE','Overdue Notice','Item Overdue','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nAccording to our current records, you have items that are overdue.Your library does not charge late fines, but please return or renew them at the branch below as soon as possible.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPhone: <<branches.branchphone>>\nFax: <<branches.branchfax>>\nEmail: <<branches.branchemail>>\n\nIf you have registered a password with the library, and you have a renewal available, you may renew online. If an item becomes more than 30 days overdue, you will be unable to use your library card until the item is returned.\n\nThe following item(s) is/are currently overdue:\n\n<item>"<<biblio.title>>" by <<biblio.author>>, <<items.itemcallnumber>>, Barcode: <<items.barcode>> Fine: <<items.fine>></item>\n\nThank-you for your prompt attention to this matter.\n\n<<branches.branchname>> Staff\n', 'email'),
('claimacquisition','ACQCLAIM','Acquisition Claim','Item Not Received','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\n<order>Ordernumber <<aqorders.ordernumber>> (<<biblio.title>>) (<<aqorders.quantity>> ordered) ($<<aqorders.listprice>> each) has not been received.</order>', 'email'),
('orderacquisition','ACQORDER','Acquisition order','Order','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\nPlease order for the library:\r\n\r\n<order>Ordernumber <<aqorders.ordernumber>> (<<biblio.title>>) (quantity: <<aqorders.quantity>>) ($<<aqorders.listprice>> each).</order>\r\n\r\nThank you,\n\n<<branches.branchname>>', 'email'),
('serial','SERIAL_ALERT','New serial issue','New serial issue is now available','<<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nThe following issue is now available:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)\r\n\r\nPlease pick it up at your convenience.', 'email'),
('members','ACCTDETAILS','Account Details Template - DEFAULT','Your new Koha account details.','Hello <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\nYour new Koha account details are:\r\n\r\nUser:  <<borrowers.userid>>\r\nPassword: <<borrowers.password>>\r\n\r\nIf you have any problems or questions regarding your account, please contact your Koha Administrator.\r\n\r\nThank you,\r\nKoha Administrator\r\nkohaadmin@yoursite.org', 'email'),
('circulation','DUE','Item Due Reminder','Item Due Reminder','Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nThe following item is now due:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)', 'email'),
('circulation','DUEDGST','Item Due Reminder (Digest)','Item Due Reminder','You have <<count>> items due', 'email'),
('circulation','PREDUE','Advance Notice of Item Due','Advance Notice of Item Due','Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nThe following item will be due soon:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)', 'email'),
('circulation','PREDUEDGST','Advance Notice of Item Due (Digest)','Advance Notice of Item Due','You have <<count>> items due soon', 'email'),
('reserves', 'HOLD', 'Hold Available for Pickup', 'Hold Available for Pickup at <<branches.branchname>>', 'Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nYou have a hold available for pickup as of <<reserves.waitingdate>>:\r\n\r\nTitle: <<biblio.title>>\r\nAuthor: <<biblio.author>>\r\nCopy: <<items.copynumber>>\r\nLocation: <<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress3>>\r\n<<branches.branchcity>> <<branches.branchzip>>', 'email'),
('reserves', 'HOLD', 'Hold Available for Pickup', 'Hold Available for Pickup (print notice)', '<<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n\r\n\r\nChange Service Requested\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>>\r\n<<borrowers.address>>\r\n<<borrowers.city>> <<borrowers.zipcode>>\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>> <<borrowers.cardnumber>>\r\n\r\nYou have a hold available for pickup as of <<reserves.waitingdate>>:\r\n\r\nTitle: <<biblio.title>>\r\nAuthor: <<biblio.author>>\r\nCopy: <<items.copynumber>>\r\n', 'print'),
('circulation','CHECKIN','Item Check-in (Digest)','Check-ins','The following items have been checked in:\r\n----\r\n<<biblio.title>>\r\n----\r\nThank you.', 'email'),
('circulation','CHECKOUT','Item Check-out (Digest)','Checkouts','The following items have been checked out:\r\n----\r\n<<biblio.title>>\r\n----\r\nThank you for visiting <<branches.branchname>>.', 'email'),
('reserves', 'HOLDPLACED', 'Hold Placed on Item', 'Hold Placed on Item','A hold has been placed on the following item : <<biblio.title>> (<<biblio.biblionumber>>) by the user <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>).', 'email'),
('reserves', 'CANCEL_HOLD_ON_LOST', 'Hold has been cancelled', "Hold has been cancelled", "Dear [% borrower.firstname %] [% borrower.surname %],\n\nWe regret to inform you, that the following item can not be provided due to it being missing. Your hold was cancelled.\n\nTitle: [% biblio.title %]\nAuthor: [% biblio.author %]\nCopy: [% item.copynumber %]\nLocation: [% branch.branchname %]", 'email'),
('suggestions','ACCEPTED','Suggestion accepted', 'Purchase suggestion accepted','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nThe library has reviewed your suggestion today. The item will be ordered as soon as possible. You will be notified by mail when the order is completed, and again when the item arrives at the library.\n\nIf you have any questions, please email us at <<branches.branchemail>>.\n\nThank you,\n\n<<branches.branchname>>', 'email'),
('suggestions','AVAILABLE','Suggestion available', 'Suggested purchase available','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nWe are pleased to inform you that the item you requested is now part of the collection.\n\nIf you have any questions, please email us at <<branches.branchemail>>.\n\nThank you,\n\n<<branches.branchname>>', 'email'),
('suggestions','ORDERED','Suggestion ordered', 'Suggested item ordered','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nWe are pleased to inform you that the item you requested has now been ordered. It should arrive soon, at which time it will be processed for addition into the collection.\n\nYou will be notified again when the book is available.\n\nIf you have any questions, please email us at <<branches.branchemail>>\n\nThank you,\n\n<<branches.branchname>>', 'email'),
('suggestions','REJECTED','Suggestion rejected', 'Purchase suggestion declined','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nThe library has reviewed your request today, and has decided not to accept the suggestion at this time.\n\nThe reason given is: <<suggestions.reason>>\n\nIf you have any questions, please email us at <<branches.branchemail>>.\n\nThank you,\n\n<<branches.branchname>>', 'email'),
('suggestions','TO_PROCESS','Notify fund owner', 'A suggestion is ready to be processed','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nA new suggestion is ready to be processed: <<suggestions.title>> by <<suggestions.author>>.\n\nThank you,\n\n<<branches.branchname>>', 'email'),
('members', 'DISCHARGE', 'Discharge', 'Discharge for <<borrowers.firstname>> <<borrowers.surname>>', '<h1>Discharge</h1>\r\n\r\nThe library <<borrowers.branchcode>> certifies that the following borrower :\r\n\r\n    <<borrowers.firstname>> <<borrowers.surname>>\r\n   Cardnumber : <<borrowers.cardnumber>>\r\n\r\nreturned all his documents.', 'email');

INSERT INTO `letter` (module, code, name, title, content, is_html)
VALUES ('circulation','ISSUESLIP','Issue Slip','Issue Slip', '<h3><<branches.branchname>></h3>
Checked out to <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(<<borrowers.cardnumber>>) <br />

<<today>><br />

<h4>Checked Out</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Barcode: <<items.barcode>><br />
Date due: <<issues.date_due>><br />
</p>
</checkedout>

<h4>Overdues</h4>
<overdue>
<p>
<<biblio.title>> <br />
Barcode: <<items.barcode>><br />
Date due: <<issues.date_due>><br />
</p>
</overdue>

<hr>

<h4 style="text-align: center; font-style:italic;">News</h4>
<news>
<div class="newsitem">
<h5 style="margin-bottom: 1px; margin-top: 1px"><b><<opac_news.title>></b></h5>
<p style="margin-bottom: 1px; margin-top: 1px"><<opac_news.content>></p>
<p class="newsfooter" style="font-size: 8pt; font-style:italic; margin-bottom: 1px; margin-top: 1px">Posted on <<opac_news.tim
estamp>></p>
<hr />
</div>
</news>', 1),
('circulation','ISSUEQSLIP','Issue Quick Slip','Issue Quick Slip', '<h3><<branches.branchname>></h3>
Checked out to <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(<<borrowers.cardnumber>>) <br />

<<today>><br />

<h4>Checked Out Today</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Barcode: <<items.barcode>><br />
Date due: <<issues.date_due>><br />
</p>
</checkedout>', 1),
('circulation','HOLD_SLIP','Hold Slip','Hold Slip', '<h5>Date: <<today>></h5>

<h3> Transfer to/Hold in <<branches.branchname>></h3>

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
', 1),
('circulation','TRANSFERSLIP','Transfer Slip','Transfer Slip', '<h5>Date: <<today>></h5>

<h3>Transfer to <<branches.branchname>></h3>

<h3>ITEM</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
</ul>', 1);

INSERT INTO `letter` (`module`,`code`,`branchcode`,`name`,`is_html`,`title`,`content`)
VALUES (
'members',  'OPAC_REG_VERIFY',  '',  'Opac Self-Registration Verification Email',  '1',  'Verify Your Account',  'Hello!

Your library account has been created. Please verify your email address by clicking this link to complete the signup process:

<<OPACBaseURL>>/cgi-bin/koha/opac-registration-verify.pl?token=<<borrower_modifications.verification_token>>

If you did not initiate this request, you may safely ignore this one-time message. The request will expire shortly.'
);

INSERT INTO `letter` (module, code, name, title, content) VALUES ('circulation','RENEWAL','Item Renewal','Renewals','The following items have been renew:\r\n----\r\n<<biblio.title>>\r\n----\r\nThank you for visiting <<branches.branchname>>.');

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
VALUES ( 'circulation', 'OVERDUES_SLIP', '', 'Overdues Slip', '0', 'OVERDUES_SLIP', 'The following item(s) is/are currently overdue:

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
