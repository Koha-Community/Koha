INSERT INTO `letter` (module, code, branchcode, name, is_html, title, content, message_transport_type) VALUES
('circulation','CHECKIN','','Retours (Résumé)',0,'Retours','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nVous venez de rendre les documents suivants :\r\n----\r\n<<biblio.title>>\r\n----\r\nMerci.\r\n\r\n<<branches.branchname>>','email'),
('circulation','CHECKOUT','','Emprunts (Résumé)',0,'Emprunts','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nVous venez d\'emprunter les documents suivants :\r\n----\r\n<<biblio.title>>\r\n----\r\nMerci.\r\n\r\n<<branches.branchname>>','email'),
('circulation','DUE','','Document à rendre aujourd\'hui',0,'Document à rendre aujourd\'hui','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nLe prêt de ce document arrive à expiration aujourd\'hui.\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)\r\n\r\nMerci de nous le retourner.\r\n\r\n<<branches.branchname>>','email'),
('circulation','DUEDGST','','Document à rendre aujourd\'hui (Résumé)',0,'Document à rendre aujourd\'hui','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nVous avez <<count>> document(s) dont le prêt arrive à expiration.\r\n\r\nMerci de nous le(s) retourner rapidement.\r\n\r\n<<branches.branchname>>','email'),
('circulation','ISSUEQSLIP','','Ticket rapide de prêts',1,'Ticket rapide de prêts','<h3><<branches.branchname>></h3>\r\nEmprunté par <<borrowers.firstname>> <<borrowers.surname>> <br />\r\n(<<borrowers.cardnumber>>) <br />\r\n\r\n<<today>><br />\r\n\r\n<h4>Emprunté(s) aujourd\'hui</h4>\r\n<checkedout>\r\n<p>\r\n<<biblio.title>><br />\r\nCode-barres : <<items.barcode>><br />\r\nDate de retour : <<issues.date_due>><br />\r\n</p>\r\n</checkedout>','email'),
('circulation','ISSUESLIP','','Ticket de prêts',1,'Ticket de prêts','<h3><<branches.branchname>></h3>\r\nEmprunté par <<borrowers.firstname>> <<borrowers.surname>> <br />\r\n(<<borrowers.cardnumber>>) <br />\r\n\r\n<<today>><br />\r\n\r\n<h4>Emprunté(s) aujourd\'hui</h4>\r\n<checkedout>\r\n<p>\r\n<<biblio.title>> <br />\r\nCode-barres : <<items.barcode>><br />\r\nDate de retour : <<issues.date_due>><br />\r\n</p>\r\n</checkedout>\r\n\r\n<h4>Retards</h4>\r\n<overdue>\r\n<p>\r\n<<biblio.title>> <br />\r\nCode-barres : <<items.barcode>><br />\r\nDate de retour : <<issues.date_due>><br />\r\n</p>\r\n</overdue>\r\n\r\n<hr>\r\n\r\n<h4 style=\"text-align: center; font-style:italic;\">Nouvelles</h4>\r\n<news>\r\n<div class=\"newsitem\">\r\n<h5 style=\"margin-bottom: 1px; margin-top: 1px\"><b><<opac_news.title>></b></h5>\r\n<p style=\"margin-bottom: 1px; margin-top: 1px\"><<opac_news.content>></p>\r\n<p class=\"newsfooter\" style=\"font-size: 8pt; font-style:italic; margin-bottom: 1px; margin-top: 1px\">Publiée le <<opac_news.published_on>></p>\r\n<hr />\r\n</div>\r\n</news>','email'),
('circulation','ODUE','','Document(s) en retard',0,'Document(s) en retard','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nSelon nos informations, vous avez au moins un document en retard. Merci de retourner ou renouveller ce ou ces documents dans votre bibliothèque le plus rapidement possible.\r\n\r\n<<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>> <<branches.branchaddress3>>\r\nTél : <<branches.branchphone>>\r\nFax : <<branches.branchfax>>\r\nCourriel : <<branches.branchemail>>\r\n\r\nSi vous avez le mot de passe de votre compte lecteur, vous pouvez renouveler directement en ligne. Sinon, merci de nous contacter.\r\n\r\nLe ou les documents suivants sont en retard :\r\n\r\n<item>\"<<biblio.title>>\" par <<biblio.author>>, <<items.itemcallnumber>>, code-barres : <<items.barcode>> Amende : <<items.fine>></item>\r\n\r\nMerci de votre attention.\r\n\r\n<<branches.branchname>>','email'),
('circulation','PREDUE','','Document à rendre bientôt',0,'Document à rendre bientôt','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nNous souhaitons vous informer que le prêt de ce document arrive bientôt à expiration :\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)\r\n\r\nMerci.\r\n\r\n<<branches.branchname>>','email'),
('circulation','PREDUEDGST','','Document à rendre bientôt (Résumé)',0,'Document(s) à rendre bientôt','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nVous avez <<count>> document(s) dont le prêt arrive bientôt à expiration.\r\n\r\n<<branches.branchname>>','email'),
('circulation','RENEWAL','','Renouvellements',0,'Renouvellements','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nVous avez renouvelé les documents suivants :\r\n----\r\n<<biblio.title>>\r\n----\r\nMerci.\r\n\r\n<<branches.branchname>>.','email'),
('circulation','HOLD_SLIP','','Ticket de réservation',1,'Ticket de réservation','<h5>Date : <<today>></h5>\r\n\r\n<h3> Transfert / Réservation disponible à <<branches.branchname>></h3>\r\n\r\n<h3><<borrowers.surname>>, <<borrowers.firstname>> </h3>\r\n\r\n<ul>\r\n    <li><<borrowers.cardnumber>></li>\r\n    <li><<borrowers.phone>></li>\r\n    <li> <<borrowers.address>><br />\r\n         <<borrowers.address2>><br />\r\n         <<borrowers.city >>  <<borrowers.zipcode>>\r\n    </li>\r\n    <li><<borrowers.email>></li>\r\n</ul>\r\n<br />\r\n<h3>DOCUMENT RÉSERVÉ</h3>\r\n<h4><<biblio.title>></h4>\r\n<h5><<biblio.author>></h5>\r\n<ul>\r\n   <li><<items.barcode>></li>\r\n   <li><<items.itemcallnumber>></li>\r\n   <li><<reserves.waitingdate>></li>\r\n</ul>\r\n<p>Notes :\r\n<pre><<reserves.reservenotes>></pre>\r\n</p>\r\n','email'),
('circulation','TRANSFERSLIP','','Ticket de transfert',1,'Ticket de transfert','<h5>Date : <<today>></h5>\r\n\r\n<h3>Transfert à <<branches.branchname>></h3>\r\n\r\n<h3>DOCUMENT</h3>\r\n<h4><<biblio.title>></h4>\r\n<h5><<biblio.author>></h5>\r\n<ul>\r\n   <li><<items.barcode>></li>\r\n   <li><<items.itemcallnumber>></li>\r\n</ul>','email'),
('claimacquisition','ACQCLAIM','','Réclamation d\'une commande',0,'Document non reçu','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\nBonjour,\r\n\r\nLa commande suivante n\'a pas été reçue par notre service d\'acquisitions.\r\n\r\n<order>Commande n. <<aqorders.ordernumber>> (<<biblio.title>>) (<<aqorders.quantity>> exemplaire(s) commandé(s)) ($<<aqorders.listprice>> / unité).</order>\r\n\r\nMerci de faire le nécessaire pour nous la faire parvenir rapidement.\r\n\r\nEn cas de problème, veuillez nous contacter à l\'adresse ci-dessous.\r\n\r\nCordialement,\r\n\r\n<<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress3>>\r\n<<branches.branchcity>> <<branches.branchzip>>\r\n<<branches.branchphone>>\r\n<<branches.branchemail>>\r\n','email'),
('orderacquisition','ACQORDER','','Commande',0,'Commande','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\nLa bibliothèque désire commander :\r\n\r\n<order>Ordernumber <<aqorders.ordernumber>> (<<biblio.title>>) (quantity: <<aqorders.quantity>>) ($<<aqorders.listprice>> chacun).</order>\r\n\r\nMerci,\n\n<<branches.branchname>>', 'email'),
('members','ACCTDETAILS','','Modèle de message pour les détails d\'un compte lecteur - DEFAULT',0,'Votre compte Koha','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nLes informations pour vous connecter à votre compte lecteur sont :\r\n\r\nIdentifiant :  <<borrowers.userid>>\r\nMot de passe: <<borrowers.password>>\r\n\r\nSi vous rencontrez des problèmes ou avez des questions concernant votre compte, veuillez contacter l\'administrateur de Koha.\r\n\r\nMerci, \r\nL\'administrateur de Koha\r\nkohaadmin@yoursite.org','email'),
('reserves','HOLD','','Réservation en attente de retrait',0,'Réservation en attente de retrait à <<branches.branchname>>','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nVotre réservation est disponible depuis le <<reserves.waitingdate>> :\r\n\r\nTitre : <<biblio.title>>\r\nAuteur : <<biblio.author>>\r\nCopie : <<items.copynumber>>\r\nLocalisation : <<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress3>>\r\n<<branches.branchcity>> <<branches.branchzip>>\r\n\r\nNous vous invitons à venir emprunter votre document rapidement.\r\n\r\nMerci.\r\n\r\n<<branches.branchname>>','email'),
('reserves','HOLD','','Réservation en attente de retrait',0,'Réservation en attente de retrait à <<branches.branchname>>','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nVotre réservation est disponible depuis le <<reserves.waitingdate>> :\r\n\r\nTitre : <<biblio.title>>\r\nAuteur : <<biblio.author>>\r\nCopie : <<items.copynumber>>\r\nLocalisation : <<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress3>>\r\n<<branches.branchcity>> <<branches.branchzip>>\r\n\r\nNous vous invitons à venir emprunter votre document rapidement.\r\n\r\nMerci.\r\n\r\n<<branches.branchname>>','print'),
('reserves','HOLDPLACED','','Réservation sur un document',0,'Un document a été réservé','Le document suivant a été réservé : \r\n<<biblio.title>> (<<biblio.biblionumber>>) par l\'adhérent <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>).','email'),
('reserves','HOLD_REMINDER','','Waiting hold reminder',0,'You have waiting holds.','Dear [% borrower.firstname %] [% borrower.surname %],\r\n\r\nThe follwing holds are waiting at [% branch.branchname %]:\r\n\\r\n[% FOREACH hold IN holds %]\r\n    [% hold.biblio.title %] : waiting since [% hold.waitingdate %]\r\n[% END %]','email'),
('reserves', 'CANCEL_HOLD_ON_LOST', '','Réservation annulée',0,"Réservation annulée", "Bonjour [% borrower.firstname %] [% borrower.surname %],\n\nVotre réservation pour le document suivant ne peut malheureusement pas être comblée parce que le document est introuvable.\n\nTitre : [% biblio.title %]\nAuteur : [% biblio.author %]\nExemplaire : [% item.copynumber %]\nLocalisation : [% branch.branchname %]", 'email'),
('serial','SERIAL_ALERT','','Liste de circulation',0,'Le nouveau numéro de <<biblio.title>> est disponible','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nLe nouveau numéro de <<biblio.title>> est disponible.\r\n\r\nVous pouvez venir à la bilbliothèque pour le consulter.\r\n\r\nMerci.\r\n\r\n<<branches.branchname>>','email'),
('suggestions','ACCEPTED','','Suggestion d\'achat acceptée',0,'Suggestion d\'achat acceptée','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nVous nous avez suggéré l\'achat du document <<suggestions.title>> par <<suggestions.author>>.\r\n\r\nNous avons évalué votre suggestion aujourdhui. Le document sera commandé dès que possible. Vous serez tenu au courant par courriel quand le document aura été commandé et quand il sera disponible à la bibliothèque.\r\n\r\nPour toute question, veuillez nous contacter à l\'adresse suivante : <<branches.branchemail>>.\r\n\r\nMerci.\r\n\r\n<<branches.branchname>>','email'),
('suggestions','AVAILABLE','','Suggestion d\'achat disponible',0,'Suggestion d\'achat disponible','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nVous nous avez suggéré l\'achat du document <<suggestions.title>> par <<suggestions.author>>.\r\n\r\nNous avons le plaisir de vous informer que le document fait aujourd\'hui partie de nos collection et qu\'il est disponible à la bibliothèque.\r\n\r\nPour toute question, veuillez nous contacter à l\'adresse suivante : <<branches.branchemail>>.\r\n\r\nMerci.\r\n\r\n<<branches.branchname>>','email'),
('suggestions','ORDERED','','Suggestion d\'achat commandée',0,'Suggestion d\'achat commandée','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nVous nous avez suggéré l\'achat du document <<suggestions.title>> par <<suggestions.author>>.\r\n\r\nNous avons le plaisir de vous informer que le document a été commandé.\r\n\r\nVous recevrez une nouvelle notification quand le document sera disponible à bibliothèque.\r\n\r\nPour toute question, veuillez nous contacter à l\'adresse suivante : <<branches.branchemail>>.\r\n\r\nMerci.\r\n\r\n<<branches.branchname>>','email'),
('suggestions','REJECTED','','Suggestion d\'achat rejetée',0,'Suggestion d\'achat rejetée','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nVous nous avez suggéré l\'achat du document <<suggestions.title>> par <<suggestions.author>>.\r\n\r\nNous avons évalué votre suggestion aujourd\'hui et décidé de ne pas l\'acheter cette fois.\r\n\r\nLa raison de notre refus est : <<suggestions.reason>>\r\n\r\nPour toute question, veuillez nous contacter à l\'adresse suivante : <<branches.branchemail>>.\r\n\r\nMerci.\r\n\r\n<<branches.branchname>>','email'),
('circulation','CHECKINSLIP','','Checkin slip',1,'Checkin slip',"<h3>[% branch.branchname %]</h3>
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
[% END %]", 'print');

INSERT INTO `letter` (module, code, name, title, content, is_html, message_transport_type)
VALUES ('suggestions','NEW_SUGGESTION','Nouvelle suggestion','Nouvelle suggestion','<h3>Suggestion en attente</h3>
    <p><h4>Suggestion de</h4>
    <ul>
    <li><<borrowers.firstname>> <<borrowers.surname>></li>
    <li><<borrowers.cardnumber>></li>
    <li><<borrowers.phone>></li>
    <li><<borrowers.email>></li>
    </ul>
    </p>
    <p><h4>Titre suggéré</h4>
    <ul>
    <li><b>Bibliothèque :</b> <<branches.branchname>></li>
    <li><b>Titre :</b> <<suggestions.title>></li>
    <li><b>Auteur :</b> <<suggestions.author>></li>
    <li><b>Date de droit d\'auteur:</b> <<suggestions.copyrightdate>></li>
    <li><b>Numéro standard (ISBN, ISSN ou autre) :</b> <<suggestions.isbn>></li>
    <li><b>Éditeur :</b> <<suggestions.publishercode>></li>
    <li><b>Collection :</b> <<suggestions.collectiontitle>></li>
    <li><b>Lieu de publication :</b> <<suggestions.place>></li>
    <li><b>Quantité :</b> <<suggestions.quantity>></li>
    <li><b>Type de document :</b>  <<suggestions.itemtype>></li>
    <li><b>Raison de la suggestion :</b> <<suggestions.patronreason>></li>
    <li><b>Notes :</b> <<suggestions.note>></li>
    </ul>
    </p>',1, 'email');
INSERT INTO `letter` (module, code, branchcode, name, is_html, title, content, message_transport_type) VALUES
('members','DISCHARGE','','Quittance',0,'Quittance pour <<borrowers.firstname>> <<borrowers.surname>>','Quittance\r\n\r\nLa bibliothèque <<borrowers.branchcode>> certifie que l\'utilisateur suivant :\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>>\r\nCardnumber : <<borrowers.cardnumber>>\r\n\r\na rendu tous ses documents.','email');

INSERT INTO `letter` (module, code, branchcode, name, is_html, title, content, message_transport_type) VALUES
('members','OPAC_REG_VERIFY','','Courriel de vérification lors d\'une auto-inscription',1,'Vérification de votre compte','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nVotre compte lecteur a été créé. Pour terminer votre inscription, veuillez confirmer votre courriel en cliquant sur ce lien : \r\n\r\n<<OPACBaseURL>>/cgi-bin/koha/opac-registration-verify.pl?token=<<borrower_modifications.verification_token>>\r\n\r\nSi vous n\'êtes pas à l\'origine de cette inscription, vous pouvez ignorer ce message. Le lien expirera sous peu.\r\n\r\nMerci.\r\n\r\n<<branches.branchname>>','email');

INSERT INTO `letter` (module, code, branchcode, name, is_html, title, content, message_transport_type) VALUES
('members','SHARE_INVITE','','Invitation pour partager une liste',0,'Partage de la liste <<listname>>','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nUn de nos lecteurs, <<borrowers.firstname>> <<borrowers.surname>>, vous invite à partager la liste <<listname>> dans le catalogue de la bibliothèque.\r\n\r\nPour voir cette liste, veuillez cliquer sur le lien suivant ou le copier/coller dans la barre d\'adresse de votre navigateur.\r\n\r\n<<shareurl>>\r\n\r\nSi vous n\'êtes pas un adhérent de notre bibliothèque ou si vous ne souhaitez pas accepter cette invitation, merci d\'ignorer ce message. Veuillez noter également que cette invitation expirera dans deux semaines.\r\n\r\nMerci.\r\n\r\n<<branches.branchname>>','email');

INSERT INTO `letter` (module, code, branchcode, name, is_html, title, content, message_transport_type) VALUES
('members','SHARE_ACCEPT','','Notification d\'acception de partage d\'une liste',0,'Le partage de la liste <<listname>> a été accepté','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nNous vous informons que <<borrowers.firstname>> <<borrowers.surname>> a accepté votre invitation à partager la liste <<listname>> dans le catalogue de la bibliothèque.\r\n\r\nMerci.\r\n\r\n<<branches.branchname>>','email');

INSERT INTO `letter` (module, code, branchcode, name, is_html, title, content, message_transport_type) VALUES
('acquisition','ACQ_NOTIF_ON_RECEIV','','Notification lors de la réception',0,'Commande reçue','Bonjour <<borrowers.firstname>> <<borrowers.surname>bbbb>,\r\n\r\nLa commande <<aqorders.ordernumber>> (<<biblio.title>>) a été reçue.\r\n\r\n<<branches.branchname>>','email');

INSERT INTO `letter` (module, code, name, title, content, message_transport_type) VALUES
('suggestions','TO_PROCESS','Notification pour le responsable du poste budgétaire', 'Une suggestion est prête à être traitée','Bonjour <<borrowers.firstname>> <<borrowers.surname>>,\n\nUne nouvelle suggestion est prête à être traitée : <<suggestions.title>> par <<suggestions.author>>.\n\nMerci,\n\n<<branches.branchname>>', 'email'),
('members', 'PROBLEM_REPORT','OPAC problem report','OPAC problem report','Username: <<problem_reports.username>>\n\nProblem page: <<problem_reports.problempage>>\n\nTitle: <<problem_reports.title>>\n\nMessage: <<problem_reports.content>>','email');

INSERT INTO `letter` (module, code, name, title, content, message_transport_type) VALUES
('suggestions', 'NOTIFY_MANAGER', 'Notify manager of a suggestion', "A suggestion has been assigned to you", "Dear [% borrower.firstname %] [% borrower.surname %],\nA suggestion has been assigned to you: [% suggestion.title %].\nThank you,\n[% branch.branchname %]", 'email');

INSERT INTO letter ( module, code, branchcode, name, is_html, title, content, message_transport_type ) VALUES
('circulation', 'OVERDUES_SLIP', '', 'Ticket pour les documents en retard', '0', 'Ticket pour les documents en retard', 'Le(s) document(s) est/sont présentement en retard :

<item>"<<biblio.title>>" par <<biblio.author>>, <<items.itemcallnumber>>, Code-barres : <<items.barcode>> Amendes : <<items.fine>></item>
', 'print' );

INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
('circulation', 'AR_CANCELED', '', 'Demande d\'article - annulation', 0, 'Demande d\'article annulée', 'Bonjour <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>),\r\n\r\nVotre demande d\'article de <<biblio.title>> (<<items.barcode>>) a été annulée pour la raison suivante :\r\n\r\n<<article_requests.notes>>\r\n\r\nArticle demandé :\r\nTitre : <<article_requests.title>>\r\nAuteur : <<article_requests.author>>\r\nVolume : <<article_requests.volume>>\r\nNuméro : <<article_requests.issue>>\r\nDate : <<article_requests.date>>\r\nPages : <<article_requests.pages>>\r\nChapitres : <<article_requests.chapters>>\r\nNotes : <<article_requests.patron_notes>>\r\n\r\nVotre bibliothèque.', 'email'),
('circulation', 'AR_COMPLETED', '', 'Demande d\'article - disponible', 0, 'L\'article demandé est disponible', 'Bonjour <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>),\r\n\r\nL\'article de <<biblio.title>> (<<items.barcode>>) que vous avez demandé est maintenant disponible.\r\n\r\nArticle demandé :\r\nTitre : <<article_requests.title>>\r\nAuteur : <<article_requests.author>>\r\nVolume : <<article_requests.volume>>\r\nNuméro : <<article_requests.issue>>\r\nDate : <<article_requests.date>>\r\nPages : <<article_requests.pages>>\r\nChapitres : <<article_requests.chapters>>\r\nNotes : <<article_requests.patron_notes>>\r\n\r\nVous pouvez venir chercher votre article à <<branches.branchname>>.\r\n\r\nMerci.', 'email'),
('circulation', 'AR_PENDING', '', 'Demande d\'article - en attente', 0, 'Demande d\'article reçue', 'Bonjour <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nNous avons bien reçu votre demande d\'article de <<biblio.title>> (<<items.barcode>>).\r\n\r\nArticle demandé :\r\nTitre : <<article_requests.title>>\r\nAuteur : <<article_requests.author>>\r\nVolume : <<article_requests.volume>>\r\nNuméro : <<article_requests.issue>>\r\nDate : <<article_requests.date>>\r\nPages : <<article_requests.pages>>\r\nChapitres : <<article_requests.chapters>>\r\nNotes : <<article_requests.patron_notes>>\r\n\r\n\r\nMerci.', 'email'),
('circulation', 'AR_SLIP', '', 'Demande d\'article - ticket', 0, 'Demande d\'article', 'Demande d\'article :\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>),\r\n\r\nTitre : <<biblio.title>>\r\nCode-barres : <<items.barcode>>\r\n\r\nArticle demandé :\r\nTitre : <<article_requests.title>>\r\nAuteur : <<article_requests.author>>\r\nVolume : <<article_requests.volume>>\r\nNuméro : <<article_requests.issue>>\r\nDate : <<article_requests.date>>\r\nPages : <<article_requests.pages>>\r\nChapitres : <<article_requests.chapters>>\r\nNotes : <<article_requests.patron_notes>>\r\n', 'print'),
('circulation', 'AR_PROCESSING', '', 'Demande d\'article - en traitement', 0, 'Demande d\'article en traitement', 'Bonjour <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>),\r\n\r\nNous traitons votre demande d\'article de <<biblio.title>> (<<items.barcode>>).\r\n\r\nArticle demandé :\r\nTitre : <<article_requests.title>>\r\nAuteur : <<article_requests.author>>\r\nVolume : <<article_requests.volume>>\r\nNuméro : <<article_requests.issue>>\r\nDate : <<article_requests.date>>\r\nPages : <<article_requests.pages>>\r\nChapitres : <<article_requests.chapters>>\r\nNotes : <<article_requests.patron_notes>>\r\n\r\nMerci.', 'email'),
('circulation', 'CHECKOUT_NOTE', '', 'Notes d\'un utilisateur sur les documents en prêt', '0', 'Notes sur les documents en prêts', '<<borrowers.firstname>> <<borrowers.surname>> a ajouté une note sur un exemplaire de <<biblio.title>> - <<biblio.author>> (<<biblio.biblionumber>>).','email');

INSERT INTO `letter` (module, code, branchcode, name, is_html, title, content, message_transport_type)
VALUES ('members','PASSWORD_RESET','','Récupération de mot de passe en ligne',1,'Récupération de mot de passe','<html>\r\n<p>Ce courriel vous a été envoyé suite à une demande de récupération de mot de passe pour le compte de <strong><<user>></strong>.\r\n</p>\r\n<p>\r\nVous pouvez créer un nouveau mot de passe en cliquant le lien suivant :\r\n<br/><a href=\"<<passwordreseturl>>\"><<passwordreseturl>></a>\r\n</p>\r\n<p>Ce lien sera valide pour 2 jours après la réception de ce courriel. Si vous ne changez pas votre mot de passe d\'ici deux jours, vous devrez faire une nouvelle demande de récuération de mot de passe..</p>\r\n<p>Merci.</p>\r\n</html>\r\n','email'),
('members','MEMBERSHIP_EXPIRY','','Expiration du compte',0,'Expitation prochaine de votre abonnement à la bibliothèque','Bonjour <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>,.\r\n\r\nVotre carte de bibliothèque expirera prochainement, le :\r\n\r\n<<borrowers.dateexpiry>>\r\n\r\nMerci,\r\n\r\nVotre bibliothèque\r\n\r\n<<branches.branchname>>','email');

INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`, `lang`) VALUES
('circulation', 'ACCOUNT_PAYMENT', '', 'Paiement', 0, 'Paiement', '[%- USE Price -%]\r\nVous avez fait un paiement de [% credit.amount * -1 | $Price %].\r\n\r\nLes frais suivants ont été acquittés :\r\n[%- FOREACH o IN offsets %]\r\nDescription : [% o.debit.description %]\r\nMontant payé : [% o.amount * -1 | $Price %]\r\nMontant en souffrance : [% o.debit.amountoutstanding | $Price %]\r\n[% END %]', 'email', 'default'),
('circulation', 'ACCOUNT_WRITEOFF', '', 'Amnistie', 0, 'Amnistie', '[%- USE Price -%]\r\nNous avons accordé une amnistie de [% credit.amount * -1 | $Price %] à votre compte.\r\n\r\nLes frais suivants ont été amnistiés :\r\n[%- FOREACH o IN offsets %]\r\nDescription: [% o.debit.description %]\r\nMontant payé : [% o.amount * -1 | $Price %]\r\nMontant en souffrance : [% o.debit.amountoutstanding | $Price %]\r\n[% END %]', 'email', 'default');

INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`, `lang`) VALUES
('circulation', 'ACCOUNT_CREDIT', '', 'Confirmation de paiement', 0, 'Confirmation de paiement', '<table>
[% IF ( LibraryName ) %]
 <tr>
    <th colspan="4" class="centerednames">
        <h3>[% LibraryName | html %]</h3>
    </th>
 </tr>
[% END %]
 <tr>
    <th colspan="4" class="centerednames">
        <h2><u>REÇU</u></h2>
    </th>
 </tr>
 <tr>
    <th colspan="4" class="centerednames">
        <h2>[% Branches.GetName( patron.branchcode ) | html %]</h2>
    </th>
 </tr>
 <tr>
    <th colspan="4">
        Reçu de [% patron.firstname | html %] [% patron.surname | html %] <br />
        Numéro de carte : [% patron.cardnumber | html %]<br />
    </th>
 </tr>
  <tr>
    <th>Date</th>
    <th>Description des frais</th>
    <th>Note</th>
    <th>Montant</th>
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
    <td colspan="3">Solde non-réglé : </td>
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
      <h2><u>FACTURE</u></h2>
    </th>
  </tr>
  <tr>
    <th colspan="5" class="centerednames">
      <h2>[% Branches.GetName( patron.branchcode ) | html %]</h2>
    </th>
  </tr>
  <tr>
    <th colspan="5" >
      Facturé à : [% patron.firstname | html %] [% patron.surname | html %] <br />
      Numéro de carte : [% patron.cardnumber | html %]<br />
    </th>
  </tr>
  <tr>
    <th>Date</th>
    <th>Description des frais</th>
    <th>Note</th>
    <th style="text-align:right;">Montant</th>
    <th style="text-align:right;">Solde</th>
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
      <td colspan="4">Solde non-réglé : </td>
      [% IF ( totalcredit ) %]<td class="credit">[% ELSE %]<td class="debit">[% END %][% total | $Price %]</td>
    </tr>
  </tfoot>
</table>', 'print', 'default');

INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
('circulation', 'SR_SLIP', '', 'Ticket de rotation automatique d\'exemplaires', 0, 'Rapport de rotation automatique d\'exemplaires', 'Rapport de rotation automatique d\'exemplaires pour [% branch.name %]:\r\n\r\n[% IF branch.items.size %][% branch.items.size %] exemplaires de cette bibliothèque à traiter.\r\n[% ELSE %]Aucun exemplaire de cette bibliothèque à traiter\r\n[% END %][% FOREACH item IN branch.items %][% IF item.reason != \'in-demand\' %]Titre : [% item.title %]\r\nAuteur : [% item.author %]\r\nCote : [% item.callnumber %]\r\nLocalisation : [% item.location %]\r\nCode-barres: [% item.barcode %]\r\nEn prêt? : [% item.onloan %]\r\nStatut : [% item.reason %]\r\nBibliothèque dépositaire : [% item.branch.branchname %] [% item.branch.branchcode %]\r\n\r\n[% END %][% END %]', 'email');
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
