INSERT IGNORE INTO `letter`
(module, code, name, title, content, message_transport_type)
VALUES
('circulation','ODUE','Avis de retard','Document en retard','Cher(e) <<borrowers.firstname>> <<borrowers.surname>>,\n\nSelon nos informations actuelles, vous avez des documents signalés en retard dans votre compte.La Bibliothèque n\'applique pas les pénalités, mais nous vous invitons à retourner ou renouveler ces documents au plus vite dans la Bibliothèque suivante.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nTéléphone: <<branches.branchphone>>\nFax: <<branches.branchfax>>\nCourriel: <<branches.branchemail>>\n\nSi vous possédez un identifiant et un mot de passe pour vous connecter à notre catalogue en ligne,vous pouvez depuis celui-ci prolonger la durée de prêt des documents. Si les documents ont plus de 3à jours de retard, vous ne pourrez plus utiliser votre carte d\'adhérent tant que les documents ne seront pas rendus.\n\nLe(s) document(s) actuellement en retard:\n\n<item>"<<biblio.title>>" de <<biblio.author>>, <<items.itemcallnumber>>, Code barres: <<items.barcode>> Pénalité: <<items.fine>></item>\n\nAvec nos remerciements.\n\n<<branches.branchname>> La banque de prêt\n', 'email'),
('claimacquisition','ACQCLAIM','Réclamation Acquisitions','Document non reçu','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\n<order>Commande <<aqorders.ordernumber>> (<<biblio.title>>) (<<aqorders.quantity>> ordered) ($<<aqorders.listprice>> each) pas encore reçue.</order>', 'email'),
('orderacquisition','ACQORDER','Acquisition order','Order','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\nPlease order for the library:\r\n\r\n<order>Ordernumber <<aqorders.ordernumber>> (<<biblio.title>>) (quantity: <<aqorders.quantity>>) ($<<aqorders.listprice>> each).</order>\r\n\r\nThank you,\n\n<<branches.branchname>>', 'email'),
('serial','SERIAL_ALERT','Liste de routage','Fascicule de périodique disponible','<<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nLe numéro suivant est disponible:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)\r\n\r\nVous pouvez venir le retirer quand vous voulez.', 'email'),
('members','ACCTDETAILS','Nouveau compte adhérent','Votre nouveau compte adhérent.','Bonjour <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\nLes informations de votre nouveau compte sont:\r\n\r\nIdentifiant:  <<borrowers.userid>>\r\nMot de passe: <<borrowers.password>>\r\n\r\nSi vous avez des questions au sujet de votre nouveau compte, merci de prendre contact à l\'acceuil de la Bibliothèque.\r\n\r\nMerci,\r\nLa Bibliothèque\r\nkohaadmin@yoursite.org', 'email'),
('circulation','DUE','Document à rendre ','Document à rendre','Cher(e) <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nLe document suivant doit être rendu aujourd\'hui:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)', 'email'),
('circulation','DUEDGST','Document à rendre (résumé)','Document à rendre','Vous avez <<count>> document(s) à rendre', 'email'),
('circulation','PREDUE','Document à rendre bientôt','Document à rendre bientôt','Cher(e) <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nLa date de retour du doucment suivant est proche:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)', 'email'),
('circulation','PREDUEDGST','Document à rendre bientôt (résumé)','Document à rendre bientôt','Vous avez <<count>> document(s) dont la date de retour est proche', 'email'),
('reserves', 'HOLD', 'Réservation disponible pour retrait', 'Réservation disponible à la banque de retrait du site <<branches.branchname>>', 'Cher(e) <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nVous avez une réservation disponible pour retrait depuis le <<reserves.waitingdate>>:\r\n\r\nTitre: <<biblio.title>>\r\nAuteur: <<biblio.author>>\r\nNuméro de fascicule: <<items.copynumber>>\r\nSite: <<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress3>>', 'email'),
('reserves', 'HOLD', 'Réservation disponible pour retrait', 'Réservation disponible à la banque de retrait du site <<branches.branchname>>', '<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>>\n\n\nLe service des réservations\n\n\n\n\n\n\n\n<<borrowers.firstname>> <<borrowers.surname>>\n<<borrowers.address>>\n<<borrowers.city>> <<borrowers.zipcode>>\n\n\n\n\n\n\n\n\n\n\n<<borrowers.firstname>> <<borrowers.surname>> <<borrowers.cardnumber>>\n\nVotre réservation est disponible pour retrait depuis le <<reserves.waitingdate>>:\r\n\r\nTitre: <<biblio.title>>\r\nAuteur: <<biblio.author>>\r\nNuméro de fascicule: <<items.copynumber>>\r\n', 'print'),
('circulation','CHECKIN','Document rendu (résumé)','Retours','Les documents suivants ont été rendus:\r\n----\r\n<<biblio.title>>\r\n----\r\nMerci.', 'email'),
('circulation','CHECKOUT','Document prêté (résumé)','Prêts','Les documents suivants ont été prêtés:\r\n----\r\n<<biblio.title>>\r\n----\r\nMerci de votre visite <<branches.branchname>>.', 'email'),
('reserves', 'HOLDPLACED', 'Demande de réservation', 'Demande de réservation','Une demande de réservation a été placée sur le document : <<biblio.title>> (<<biblio.biblionumber>>) par l\'adhérent <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>).', 'email'),
('reserves', 'CANCEL_HOLD_ON_LOST', 'Hold has been cancelled', "Hold has been cancelled", "Dear [% borrower.firstname %] [% borrower.surname %],\n\nWe regret to inform you, that the following item can not be provided due to it being missing. Your hold was cancelled.\n\nTitle: [% biblio.title %]\nAuthor: [% biblio.author %]\nCopy: [% item.copynumber %]\nLocation: [% branch.branchname %]", 'email'),
('suggestions','ACCEPTED','Suggestion accceptée', 'Suggestion acceptée','Cher(e) <<borrowers.firstname>> <<borrowers.surname>>,\n\nVous avez crée une suggestion d\'achat au sujet du document <<suggestions.title>> de <<suggestions.author>>.\n\nLa Bibliothèque a reçu votre demande ce jour. Nous donnerons suite à votre demande aussi vite que possible. Vous serez averti par courriel dès que la commande sera envoyée,et quand les documents seront arrivés à la Bibliothèque.\n\nSi vous avez des questions, merci de nous contacter à l\'adresse suivante <<branches.branchemail>>.\n\nMerci,\n\n<<branches.branchname>>', 'email'),
('suggestions','AVAILABLE','Suggestion disponible', 'Suggestion d\'achat disponible','cher(e) <<borrowers.firstname>> <<borrowers.surname>>,\n\nVous avez effectué une suggestion d\'achat pour le docuement  <<suggestions.title>> de <<suggestions.author>>.\n\nNous sommes heureux de vous informer que le document que vous aviez demandé est maintenant disponible dans nos collections.\n\nSi vous avez des questions, merci de nous contacter par courriel à l\'adresse <<branches.branchemail>>.\n\nMerci,\n\n<<branches.branchname>>', 'email'),
('suggestions','ORDERED','Suggestion commandée', 'Suggestion commandée','Cher(e) <<borrowers.firstname>> <<borrowers.surname>>,\n\nVous avez effectué une demande de suggestion d\'achat sur le docuement <<suggestions.title>> de <<suggestions.author>>.\n\nNous sommes heureux de vous informer que le document que vous avez demandé est maintenant en commande. Le document devrait arriver rapidement dans nos collections.\n\nVous serez averti quand le docuement sera disponible.\n\nSi vous avez des questions, merci de nous contacter à l\'adresse <<branches.branchemail>>\n\nMerci,\n\n<<branches.branchname>>', 'email'),
('suggestions','REJECTED','Suggestion rejetée', 'Suggestion d\'achat rejeté','Cher(e) <<borrowers.firstname>> <<borrowers.surname>>,\n\nVous avez fait la demande du document <<suggestions.title>> de <<suggestions.author>>.\n\nla Bibliothèque a examiné votre demande ce jour, et a décidé de ne pas retenir la suggestion pour l\'instant.\n\nLa raison est la suivante: <<suggestions.reason>>\n\nSi vous avez des questions, merci de nous contacter à l\'adresse <<branches.branchemail>>.\n\nMerci,\n\n<<branches.branchname>>', 'email'),
('suggestions','TO_PROCESS','Avis au propriétaire du poste budgétaire', 'Une suggestion est prête à être traitée','<<borrowers.firstname>> <<borrowers.surname>>,\n\nUne nouvelle suggestion est prête à être traitée : <<suggestions.title>> / <<suggestions.author>>.\n\nMerci,\n\n<<branches.branchname>>', 'email'),
('members', 'DISCHARGE', 'Quitus', 'Quitus pour <<borrowers.firstname>> <<borrowers.surname>>', '<h1>Quitus</h1>\r\n\r\nLa librairie <<borrowers.branchcode>> certifies que lecteur suivant :\r\n\r\n    <<borrowers.firstname>> <<borrowers.surname>>\r\n   Numéro de carte : <<borrowers.cardnumber>>\r\n\r\na bien retourné tous ses documents.', 'email');

INSERT INTO `letter` (module, code, name, title, content, is_html)
VALUES ('circulation','ISSUESLIP','Ticket de de prêt','Ticket de prêt', '<h3><<branches.branchname>></h3>
Prêts à <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(<<borrowers.cardnumber>>) <br />

<<today>><br />

<h4>Emprunts</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Code à barres : <<items.barcode>><br />
Retour le : <<issues.date_due>><br />
</p>
</checkedout>

<h4>Retards</h4>
<overdue>
<p>
<<biblio.title>> <br />
Codes à barres : <<items.barcode>><br />
Retour le : <<issues.date_due>><br />
</p>
</overdue>

<hr>

<h4 style="text-align: center; font-style:italic;">Nouvelles</h4>
<news>
<div class="newsitem">
<h5 style="margin-bottom: 1px; margin-top: 1px"><b><<opac_news.title>></b></h5>
<p style="margin-bottom: 1px; margin-top: 1px"><<opac_news.content>></p>
<p class="newsfooter" style="font-size: 8pt; font-style:italic; margin-bottom: 1px; margin-top: 1px">Posted on <<opac_news.timestamp>></p>
<hr />
</div>
</news>', 1),
('circulation','ISSUEQSLIP','Ticket rapide','Ticket rapide', '<h3><<branches.branchname>></h3>
Prêts à <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(<<borrowers.cardnumber>>) <br />

<<today>><br />

<h4>Emprunts du jour</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Code à barres : <<items.barcode>><br />
Retour le : <<issues.date_due>><br />
</p>
</checkedout>', 1),
('circulation','HOLD_SLIP','Ticket de réservation','Ticket de réservation', '<h5>Date : <<today>></h5>

<h3> Transfert vers/Réservé à <<branches.branchname>></h3>

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
<h3>RESERVATIONS</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
   <li><<reserves.waitingdate>></li>
</ul>
<p>Notes :
<pre><<reserves.reservenotes>></pre>
</p>
', 1),
('circulation','TRANSFERSLIP','Ticket de transfer','Ticket de transfert', '<h5>Date : <<today>></h5>

<h3>Transfert à <<branches.branchname>></h3>

<h3>Titres</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
</ul>', 1);

INSERT INTO `letter` (`module`,`code`,`branchcode`,`name`,`is_html`,`title`,`content`)
VALUES (
'members',  'OPAC_REG_VERIFY',  '',  'Vérification de l''email donné à l''auto-inscription OPAC',  '1',  'Vérification de votre compte',  'Bonjour,

Votre compte de bibliothèque a été créé. Veuillez valider votre adresse email et le processus d''inscription en cliquant sur ce lien:

<<OPACBaseURL>>/cgi-bin/koha/opac-registration-verify.pl?token=<<borrower_modifications.verification_token>>

Si vous n''êtes pas à l''origine de cette inscription, vous pouvez ignorer ce message.'
);

INSERT INTO `letter` (module, code, name, title, content) VALUES ('circulation','RENEWAL','Renouvellements','Renouvellements','Les documents suivants ont été renouvelés\r\n----\r\n<<biblio.title>>\r\n----\r\nMerci, <<branches.branchname>>.');

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
