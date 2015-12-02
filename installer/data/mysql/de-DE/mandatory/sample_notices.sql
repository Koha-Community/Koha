INSERT INTO `letter` (module, code, name, title, content, message_transport_type)
VALUES ('circulation','ODUE','Mahnung','Mahnung','Liebe/r <<borrowers.firstname>> <<borrowers.surname>>,\n\nNach unseren Unterlagen haben Sie Medien entliehen, die nun überfällig geworden sind. Unsere Bibliothek erhebt keine Mahngebühren, bitte geben Sie die entliehenen Medien schnellstmöglich zurück.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nTelefon: <<branches.branchphone>>\nFax: <<branches.branchfax>>\nEmail: <<branches.branchemail>>\n\nSie können die überfälligen Medien soweit möglich auch direkt über Ihr Benutzerkonto online verlängern. Wenn ein Medium länger als 30 Tage überfällig ist, wird Ihr Benutzeraccount gesperrt und Sie können keine Medien mehr entleihen.\n\nDie folgenden Medien sind zur Zeit überfällig:\n\n<item>"<<biblio.title>>" von <<biblio.author>>, <<items.itemcallnumber>>, Barcode: <<items.barcode>> Gebühr: <<items.fine>></item>\n\nVielen Dank für die schnelle Erledigung.\n\n< Ihr Bibliotheksteam\n', 'email'),
('claimacquisition','ACQCLAIM','Reklamation (Erwerbung)','Titel nicht eingetroffen','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\n<order>Ordernumber <<aqorders.ordernumber>> (<<aqorders.title>>) (<<aqorders.quantity>> bestellt) (je $<<aqorders.listprice>>) sind nicht eingetroffen.</order>', 'email'),
('orderacquisition','ACQORDER','Bestellung (Erwerbung)','Bestellung','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\nBitte bestellen Sie für die Bibliothek:\r\n\r\n<order>Bestelnummer <<aqorders.ordernumber>> (<<biblio.title>>) (Anzahl: <<aqorders.quantity>>) (je <<aqorders.listprice>>).</order>\r\n\r\nVielen Dank,\n\n<<branches.branchname>>', 'email'),
('serial','SERIAL_ALERT','Neues Heft zugegangen','Zeitschrift ist jetzt verfügbar','<<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nDas folgende Heft ist jetzt verfügbar:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)\r\n\r\nBitte holen Sie es sobald möglich ab.', 'email'),
('members','ACCTDETAILS','Kontoinformationen - Standard','Ihr neues Benutzerkonto','Liebe/r <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\nDie Daten Ihres neuen Benutzerkontos sind:\r\n\r\nBenutzer:  <<borrowers.userid>>\r\nPasswort: <<borrowers.password>>\r\n\r\nWenn Sie Probleme in Hinsicht auf Ihr Benutzerkonto haben, wenden Sie sich bitte an die Bibliothek.\r\n\r\nVielen Dank,\r\nIhr Bibliotheksteam', 'email'),
('circulation','DUE','Fälligkeitsbenachrichtigung','Fälligkeitsbenachrichtigung','Liebe/r <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nDie folgenden Medien sind ab heute fällig:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)', 'email'),
('circulation','DUEDGST','Fälligkeitsbenachrichtigung (Zusammenfassung)','Fälligkeitsbenachrichtigung','Sie haben <<count>> überfällige Medien.', 'email'),
('circulation','PREDUE','Erinnerungsbenachrichtigung','Erinnerungsbenachrichtigung','Liebe/r <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nFolgende Ausleihe wird bald fällig:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)', 'email'),
('circulation','PREDUEDGST','Erinnerungsbenachrichtigung (Zusammenfassung)','Erinnerungsbenachrichtigung','Sie haben <<count>> Ausleihen, die bald fällig werden.', 'email'),
('circulation','RENEWAL','Verlängerungsbenachrichtigung','Verlängerungsquittung','Liebe/r <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nFolgede Exemplare wurden verlängert:\r\n----\r\n<<biblio.title>>\r\n----\r\nVielen Dank,\r\n<<branches.branchname>>.', 'email'),
('reserves', 'HOLD', 'Vormerkbenachrichtigung', 'Vormerkung abholbereit in <<branches.branchname>>', 'Liebe/r <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nFür Sie liegt seit <<reserves.waitingdate>> eine Vormerkung zur Abholung bereit:\r\n\r\nTitel: <<biblio.title>>\r\nVerfasser: <<biblio.author>>\r\nExemplar: <<items.copynumber>>\r\nStandort: <<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress3>>\r\n<<branches.branchcity>> <<branches.branchzip>>', 'email'),
('reserves', 'HOLD', 'Vormerkbenachrichtigung', 'Vormerkbenachrichtigung (Print)', '<<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchzip>> <<branches.branchcity>>\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>>\r\n<<borrowers.address>>\r\n<<borrowers.address2>>\r\n<<borrowers.zipcode>> <<borrowers.city>>\r\n<<borrowers.country>>\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\nLiebe(r) <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nFür Sie liegt seit dem <<reserves.waitingdate>> eine Vormerkung zur Abholung bereit:\r\n\r\nTitel: <<biblio.title>>\r\nVerfasser: <<biblio.author>>\r\nSignatur: <<items.itemcallnumber>>\r\n', 'print'),
('circulation','CHECKIN','Rückgabequittung (Zusammenfassung)','Rückgabequittung','Die folgenden Medien wurden zurückgegeben:\r\n----\r\n[% biblio.title %]\r\n----\r\nVielen Dank.', 'email'),
('circulation','CHECKOUT','Ausleihquittung (Zusammenfassung)','Ausleihquittung','Die folgenden Medien wurden entliehen:\r\n----\r\n[% biblio.title %]\r\n----\r\nVielen Dank für Ihren Besuch in [% branch.branchname %].', 'email'),
('reserves', 'HOLDPLACED', 'Neue Vormerkung', 'Neue Vormerkung','Folgender Titel wurde vorgemerkt: <<biblio.title>> (<<biblio.biblionumber>>) durch den Benutzer <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>).', 'email'),
('reserves', 'CANCEL_HOLD_ON_LOST', 'Vormerkung wurde storniert', "Vormerkung wurde storniert", "Liebe(r) [% borrower.firstname %] [% borrower.surname %],\n\nWir bedauern Ihnen mitteilen zu müssen, dass die nachfolgende Vormerkung nicht erfüllt werden kann, da das vorgemerkte Medium vermisst wird. Ihre Vormerkung wurde storniert.\n\nTitel: [% biblio.title %]\nVerfasser: [% biblio.author %]\nExemplar: [% item.copynumber %]\nBibliothek: [% branch.branchname %]", 'email'),
('suggestions','ACCEPTED','Anschaffungsvorschlag wurde angenommen', 'Ihr Anschaffungsvorschlag wurde angenommen','Liebe(r) <<borrowers.firstname>> <<borrowers.surname>>,\n\nSie haben der Bibliothek folgendes Medium zur Anschaffung vorgeschlagen: <<suggestions.title>> von <<suggestions.author>>.\n\nDie Bibliothek hat diesen Titel heute recherchiert und wird Ihn sobald wie möglich im Buchhandel bestellen. Sie erhalten Nachricht, sobald die Bestellung abgeschlossen ist und sobald der Titel in der Bibliotek verfügbar ist.\n\nWenn Sie Fragen haben, richten Sie Ihre Mail bitte an: <<branches.branchemail>>.\n\nVielen Dank,\n\n<<branches.branchname>>', 'email'),
('suggestions','AVAILABLE','Vorgeschlagenes Medium verfügbar', 'Das vorgeschlagene Medium ist jetzt verfügbar','Liebe(r) <<borrowers.firstname>> <<borrowers.surname>>,\n\nSie haben der Bibliothek folgendes Medium zur Anschaffung vorgeschlagen: <<suggestions.title>> von <<suggestions.author>>.\n\nWir freuen uns Ihnen mitteilen zu können, dass dieser Titel jetzt im Bestand der Bibliothek verfügbar ist.\n\nWenn Sie Fragen haben, richten Sie Ihre Mail bitte an: <<branches.branchemail>>.\n\nVielen Dank,\n\n<<branches.branchname>>', 'email'),
('suggestions','ORDERED','Vorgeschlagenes Medium bestellt', 'Das vorgeschlagene Medium wurde im Buchhandel bestellt','Liebe(r) <<borrowers.firstname>> <<borrowers.surname>>,\n\nSie haben der Bibliothek folgendes Medium zur Anschaffung vorgeschlaten: <<suggestions.title>> von <<suggestions.author>>.\n\nWir freuen uns Ihnen mitteilen zu können, dass dieser Titel jetzt im Buchhandel bestellt wurde. Nach Eintreffen wird er in unseren Bestand eingearbeitet.\n\nSie erhalten Nachricht, sobald das Medium verfügbar ist.\n\nBei Nachfragen erreichen Sie uns unter der Emailadresse <<branches.branchemail>>.\n\nVielen Dank,\n\n<<branches.branchname>>', 'email'),
('suggestions','REJECTED','Anschaffungsvorschlag nicht angenommen', 'Ihr Anschaffungsvorschlag wurde nicht angenommen','Liebe(r) <<borrowers.firstname>> <<borrowers.surname>>,\n\nSie haven der Bibliothek folgendes Medium zur Anschaffung vorgeschlagen: <<suggestions.title>> von <<suggestions.author>>.\n\nDie Bibliothek hat diesen Titel heute recherchiert und sich gegen eine Anschaffung entschieden.\n\nBegründung: <<suggestions.reason>>\n\nWenn Sie Fragen haben, richten Sie Ihre Mail bitte an: <<branches.branchemail>>.\n\nVielen Dank,\n\n<<branches.branchname>>', 'email'),
('suggestions','TO_PROCESS','Benachrichtigung an Besitzer des Kontos', 'Anschaffungsvorschlag wartet auf Bearbeitung','Liebe(r) <<borrowers.firstname>> <<borrowers.surname>>,\n\nEin neuer Anschaffungsvorschlag wartet auf Bearbeitung: <<suggestions.title>> von <<suggestions.author>>.\n\nVielen Dank,\n\n<<branches.branchname>>', 'email');

INSERT INTO `letter` (module, code, name, title, content, is_html, message_transport_type)
VALUES ('members', 'DISCHARGE', 'Entlastung', 'Entlastung für <<borrowers.firstname>> <<borrowers.surname>>', '
<<today>>
<h1>Entlastungsbescheinigung</h1>
<p><<branches.branchname>> bestätigt, dass der nachfolgende Benutzer:<br>
<<borrowers.firstname>> <<borrowers.surname>> (Ausweisnummer: <<borrowers.cardnumber>>)<br>
alle Medien zurückgegeben und ausstehende Gebühren beglichen hat.</p>', 1, 'email');

INSERT INTO `letter` (module, code, name, title, content, is_html)
VALUES ('circulation','ISSUESLIP','Ausleihquittung (Quittungsdruck)','Ausleihquittung (Quittungsdruck)', '<h2>Ausleihquittung</h2>
Ausgeliehen an: <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(<<borrowers.cardnumber>>) <br />

<<today>><br />
<br />
<h4>Ausleihen</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Signatur: <<items.itemcallnumber>><br/>
Barcode: <<items.barcode>><br />
Fällig am: <<issues.date_due>><br />
</p>
</checkedout>
<br />
<h4>Überfällig</h4>
<overdue>
<p>
<<biblio.title>> <br />
Signatur: <<items.itemcallnumber>><br/>
Barcode: <<items.barcode>><br />
Fällig am: <<issues.date_due>><br />
</p>
</overdue>
<news>
<div class="newsitem">
<h5 style="margin-bottom: 1px; margin-top: 1px"><b><<opac_news.title>></b></h5>
<p style="margin-bottom: 1px; margin-top: 1px"><<opac_news.content>></p>
<p class="newsfooter" style="font-size: 8pt; font-style:italic; margin-bottom: 1px; margin-top: 1px"><<opac_news.timestamp>></p>
<hr />
</div>
</news>', 1),
('circulation','ISSUEQSLIP','Kurzquittung','Kurzquittung', '<h2>Ausleihquittung</h2>
Bibliothek: <<branches.branchname>> <br/>
Ausleihe an: <<borrowers.firstname>>  <<borrowers.surname>> <br />
Ausweisnummer: <<borrowers.cardnumber>> <br />
<br />
<<today>><br />
<br />
<h4>Heutige Ausleihen</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Barcode: <<items.barcode>><br />
Signatur: <<items.itemcallnumber>><br/>
Fällig am: <<issues.date_due>><br />
</p>
</checkedout>', 1),
('circulation','HOLD_SLIP','Vormerkquittung','Vormerkquittung', '<h5>Datum: <<today>></h5>

<h3> Transport nach/Vormerkung in <<branches.branchname>></h3>

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
<h3>EXEMPLAR VORGEMERKT</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
   <li><<reserves.waitingdate>></li>
</ul>
<p>Anmerkungen:
<pre><<reserves.reservenotes>></pre>
</p>
', 1),
('circulation','TRANSFERSLIP','Transportquittung','Transportquittung', '<h5>Datum: <<today>></h5>

<h3>Transport nach <<branches.branchname>></h3>

<h3>EXEMPLAR</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
</ul>', 1);

INSERT INTO `letter` (`module`,`code`,`branchcode`,`name`,`is_html`,`title`,`content`)
VALUES (
'members',  'OPAC_REG_VERIFY',  '',  'Bestätigung der Anmeldung zur Bibliotheksnutzung',  '1',  'E-Mail-Adresse für Benutzerkonto verifizieren',  'Guten Tag,

Ihr Bibliothekskonto wurde angelegt. Bitte bestätigen Sie Ihre E-Mail-Adresse indem Sie auf folgenden Link klicken:

<<OPACBaseURL>>/cgi-bin/koha/opac-registration-verify.pl?token=<<borrower_modifications.verification_token>>

Wenn Sie keine Kontoanmeldung durchgeführt haben, können Sie diese Benachrichtigung ignorieren. Sie wird in Kürze ungültig.

Vielen Dank,
Ihr Bibliotheksteam'
);

INSERT INTO  letter (module, code, branchcode, name, is_html, title, content)
VALUES ('members', 'SHARE_INVITE', '', 'Einladung zum Teilen einer Liste', '0', 'Teilen der Liste <<listname>>', 'Lieber Benutzer,

Einer unserer Benutzer, <<borrowers.firstname>> <<borrowers.surname>>, möchte die Liste <<listname>> über unseren Bibliothekskatalog mit Ihnen teilen.

Um die Liste aufzurufen, klicken Sie bitte die untenstehende URL oder kopieren Sie diese in die Adresszeile Ihres Browsers:

<<shareurl>>

Im Fall dass Sie kein Benutzer unserer Bibliothek sind und diese Einladung nicht annehmen möchten, ignorieren Sie bitte diese E-Mail.
Bitte beachten Sie, dass die Einladung nach zwei Wochen ungültig wird.

Vielen Dank,
Ihr Bibliotheksteam'
);
INSERT INTO  letter (module, code, branchcode, name, is_html, title, content)
VALUES ( 'members', 'SHARE_ACCEPT', '', 'Angenommene Einladung zum Teilen einer Liste', '0', 'Einladung für Liste <<listname>> angenommen', 'Lieber Benutzer,

Wir möchten Sie darüber informieren, dass der Benutzer <<borrowers.firstname>> <<borrowers.surname>> Ihre Einladung zum teilen der Liste <<listname>> über unseren Bibliothekskatalog angenommen hat.

Vielen Dank,
Ihr Biblioheksteam'
);

INSERT INTO letter(module, code, branchcode, name, title, content, message_transport_type)
VALUES ('acquisition', 'ACQ_NOTIF_ON_RECEIV', '', 'Benachrichtigung bei Zugang', 'Bestelltes Medium ist eingetroffen', 'Liebe/r <<borrowers.firstname>> <<borrowers.surname>>,\n\nDie Bestellung <<aqorders.ordernumber>> (<<biblio.title>>) ist eingetroffen und wird bearbeitet.\n\nIhr Bibliotheksteam', 'email'),
('members','MEMBERSHIP_EXPIRY','','Ablauf des Benutzerkontos','Benutzerkonto läuft ab','Liebe(r) <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nIhr Bibliotheksausweis läuft demnächst ab:\r\n\r\n<<borrowers.dateexpiry>>\r\n\r\nVielen Dank,\r\n\r\nLibrarian\r\n\r\n<<branches.branchname>>','email');

INSERT INTO letter ( module, code, branchcode, name, is_html, title, content, message_transport_type )
VALUES ( 'circulation', 'OVERDUES_SLIP', '', 'Überfälligkeiten (Quittung)', '0', 'OVERDUES_SLIP', 'Die folgenden Exemplare sind aktuell überfällig:

<item>"<<biblio.title>>" von <<biblio.author>>, <<items.itemcallnumber>>, Barcode: <<items.barcode>> Gebühr: <<items.fine>></item>
', 'print' );

INSERT INTO `letter` (module, code, branchcode, name, is_html, title, content, message_transport_type)
VALUES ('members','PASSWORD_RESET','','Neues Passwort',1,'Neues Passwort','<html>\r\n<p>Liebe(r) <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>,</p>\r\n\r\n<p>Diese E-Mail wurde verschickt, da Sie ein neues Passwort für Ihr Bibliotheksbenutzerkonto angefordert haben: <strong><<user>></strong>.\r\n</p>\r\n<p>\r\nBitte klicken Sie auf den folgenden Link um Ihr neues Passwort zu erstellen:\r\n<br/><a href=\"<<passwordreseturl>>\"><<passwordreseturl>></a>\r\n</p>\r\n<p>Dieser Link ist von dieser E-Mail an für 2 Tage gültig. Wenn Sie bis dahin Ihr Passwort nicht geändert haben, müssen Sie die E-Mail erneut anfordern.</p>\r\n<p>Vielen Dank</p>\r\n</html>\r\n','email'
);

INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
('circulation', 'AR_CANCELED', '', 'Artikelbestellung - Storniert', 0, 'Artikelbestellung wurde storniert', 'Liebe/r <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nIhre Bestellung eines Artikels aus <<biblio.title>> (<<items.barcode>>) wurde aus folgendem Grund storniert:\r\n\r\n<<article_requests.notes>>\r\n\r\nBestellter Artikel:\r\nTitel: <<article_requests.title>>\r\nVerfasser: <<article_requests.author>>\r\nBand/Jahrgang: <<article_requests.volume>>\r\nHeft: <<article_requests.issue>>\r\nJahr/Datum: <<article_requests.date>>\r\nSeiten: <<article_requests.pages>>\r\nKapitel: <<article_requests.chapters>>\r\nHinweise: <<article_requests.patron_notes>>\r\n\r\nIhr Bibliotheksteam', 'email'),
('circulation', 'AR_COMPLETED', '', 'Artikelbestellung - Abgeschlossen', 0, 'Artikelbestellung ist abgeschlossen', 'Liebe/r <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nDer bestellte Artikel aus <<biblio.title>> (<<items.barcode>>) liegt nun zur Abholung bereit.\r\n\r\nBestellter Artikel:\r\nTitel: <<article_requests.title>>\r\nVerfasser: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nHeft: <<article_requests.issue>>\r\nJahr/Datum: <<article_requests.date>>\r\nSeiten: <<article_requests.pages>>\r\nKapitel: <<article_requests.chapters>>\r\nHinweise: <<article_requests.patron_notes>>\r\n\r\nSie können den Artikel in <<branches.branchname>> abholen.\r\n\r\nVielen Dank!', 'email'),
('circulation', 'AR_PENDING', '', 'Artikelbestellung - Offen', 0, 'Artikelbestellung ist eingegangen', 'Liebe/r <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nIhre Artikelbestellung aus <<biblio.title>> (<<items.barcode>>) ist bei uns eingegangen.\r\n\r\nBestellter Artikel:\r\nTitel: <<article_requests.title>>\r\nVerfasser: <<article_requests.author>>\r\nJahrgang/Band: <<article_requests.volume>>\r\nHeft: <<article_requests.issue>>\r\nJahr/Datum: <<article_requests.date>>\r\nSeiten: <<article_requests.pages>>\r\nKapitel: <<article_requests.chapters>>\r\nHinweise: <<article_requests.patron_notes>>\r\n\r\n\r\nVielen Dank!', 'email'),
('circulation', 'AR_SLIP', '', 'Artikelbestellung - Quittung', 0, 'Artikelbestellung', 'Artikelbestellung:\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nTitel: <<biblio.title>>\r\nBarcode: <<items.barcode>>\r\n\r\nBestellter Artikel:\r\nTitle: <<article_requests.title>>\r\nVerfasser: <<article_requests.author>>\r\nJahrgang/Band: <<article_requests.volume>>\r\nHeft: <<article_requests.issue>>\r\nJahr/Datum: <<article_requests.date>>\r\nSeiten: <<article_requests.pages>>\r\nKapitel: <<article_requests.chapters>>\r\nHinweise: <<article_requests.patron_notes>>\r\n', 'print'),
('circulation', 'AR_PROCESSING', '', 'Artikelbestellung - In Bearbeitung', 0, 'Artikelbestellung in Bearbeitung', 'Liebe/r <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nIhre Artikelbestellung aus <<biblio.title>> (<<items.barcode>>) wird zur Zeit bearbeitet.\r\n\r\nBestellter Artikel:\r\nTitel: <<article_requests.title>>\r\nVerfasser: <<article_requests.author>>\r\nBand/Jahrgang: <<article_requests.volume>>\r\nHeft: <<article_requests.issue>>\r\nJahr/Datum: <<article_requests.date>>\r\nSeiten: <<article_requests.pages>>\r\nKapitel: <<article_requests.chapters>>\r\nHinweise: <<article_requests.patron_notes>>\r\n\r\nVielen Dank!', 'email'),
('circulation', 'CHECKOUT_NOTE', '', 'Ausleihnotiz zu einem Exemplar', '0', 'Ausleihnotiz', '<<borrowers.firstname>> <<borrowers.surname>> hat eine Notiz zu folgendem Exemplar angegeben: <<biblio.title>> - <<biblio.author>> (<<biblio.biblionumber>>).','email');
INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`, `lang`)
    VALUES
        ('circulation', 'ACCOUNT_PAYMENT', '', 'Account payment', 0, 'Account payment', '[%- USE Price -%]\r\nA payment of [% credit.amount * -1 | $Price %] has been applied to your account.\r\n\r\nThis payment affected the following fees:\r\n[%- FOREACH o IN offsets %]\r\nDescription: [% o.debit.description %]\r\nAmount paid: [% o.amount * -1 | $Price %]\r\nAmount remaining: [% o.debit.amountoutstanding | $Price %]\r\n[% END %]', 'email', 'default'),
            ('circulation', 'ACCOUNT_WRITEOFF', '', 'Account writeoff', 0, 'Account writeoff', '[%- USE Price -%]\r\nAn account writeoff of [% credit.amount * -1 | $Price %] has been applied to your account.\r\n\r\nThis writeoff affected the following fees:\r\n[%- FOREACH o IN offsets %]\r\nDescription: [% o.debit.description %]\r\nAmount paid: [% o.amount * -1 | $Price %]\r\nAmount remaining: [% o.debit.amountoutstanding | $Price %]\r\n[% END %]', 'email', 'default');
INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
('circulation', 'SR_SLIP', '', 'Stock Rotation Slip', 0, 'Stockrotation Report', 'Stockrotation report for [% branch.name %]:\r\n\r\n[% IF branch.items.size %][% branch.items.size %] items to be processed for this branch.\r\n[% ELSE %]No items to be processed for this branch\r\n[% END %][% FOREACH item IN branch.items %][% IF item.reason ne \'in-demand\' %]Title: [% item.title %]\r\nAuthor: [% item.author %]\r\nCallnumber: [% item.callnumber %]\r\nLocation: [% item.location %]\r\nBarcode: [% item.barcode %]\r\nOn loan?: [% item.onloan %]\r\nStatus: [% item.reason %]\r\nCurrent Library: [% item.branch.branchname %] [% item.branch.branchcode %]\r\n\r\n[% END %][% END %]', 'email');
