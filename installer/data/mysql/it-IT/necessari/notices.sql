INSERT INTO letter (module, code, name, title, content, message_transport_type)
VALUES ('circulation','ODUE','Avviso per i ritardi','Avviso per i ritardi','Salve <<borrowers.firstname>> <<borrowers.surname>>,\n\nSecondo le nostre registrazioni, hai dei prestiti in ritard.La biblioteca non dà multe per i ritardi, ma ti chiederemmo di restituirli o di rinnovarli il prima possibile presso la biblioteca:\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nTel:: <<branches.branchphone>>\nFax: <<branches.branchfax>>\nEmail: <<branches.branchemail>>\n\nSe ti sei registrato e hai una login con una password e quei prestiti sono rinnovabili, puoi provare a rinnovarli online. Se il prestito ha un ritardo superiore a 30 giorni, probabilmente non puoi rinnovarli.\n\nRisultano in ritardo:\n\n<item>"<<biblio.title>>" di <<biblio.author>>, <<items.itemcallnumber>>, codice a barre: <<items.barcode>> Multa: <<items.fine>></item>\n\nGrazie per l\'attenzione.\n\nLo staff della <<branches.branchname>> \n', 'email'),
('claimacquisition','ACQCLAIM','Sollecito al fornitore','Sollecito al fornitore','Salve <<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\n Questi ordini non ci sono giunti:\r\n\r\n<order>Ordernumber <<aqorders.ordernumber>> (<<aqorders.title>>) (<<aqorders.quantity>> ordinati) ($<<aqorders.listprice>> l\'uno).</order>', 'email'),
('orderacquisition','ACQORDER','Ordine da ACQ','Ordine','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\nLe chiediamo di ordinare questi libri per la biblioteca:\r\n\r\n<order>Numero ordine <<aqorders.ordernumber>> (<<biblio.title>>) (quantità: <<aqorders.quantity>>) (<<aqorders.listprice>> EUR l\'uno).</order>\r\n\r\nGrazie,\n\n<<branches.branchname>>', 'email'),
('serial','SERIAL_ALERT','New serial issue','New serial issue is now available','Caro <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nQuesta pubblicazione è ora disponibile:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)\r\n\r\nPassa a prenderla presso il banco distribuzione.', 'email'),
('members','ACCTDETAILS','Messaggio per i nuovi utenti registrati','Messaggio per i nuovi utenti registrati.','Salve <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\nI dettagli del tuo nuovo account per la biblioteca sono:\r\n\r\nLogin:  <<borrowers.userid>>\r\nPassword: <<borrowers.password>>\r\n\r\nSe hai domande o problemi sul tuo account, contattaci a questo indirizzo e-mail: youremailadmin@library.it.\r\nGrazie di tutto\r\n\r\nLo staff della biblioteca\r\n', 'email'),
('circulation','DUE','Avviso restituzione (copia singola)','Avviso restituzione (copia singola)','Salve <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nQuesto prestito è ora in ritardo:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)', 'email'),
('circulation','DUEDGST','Avviso restituzione (digest)','Avviso restituzione (digest)','Hai <<count>> prestiti da retituire', 'email'),
('circulation','PREDUE','Preavviso scadenza prestito','Preavviso scadenza prestito','Salve <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nQuesti prestiti stanno per scadere:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)', 'email'),
('circulation','PREDUEDGST','Preavviso scadenza prestiti (digest)','Avviso copie in scadenza','Gentile <<borrowers.firstname>> <<borrowers.surname>>,
Il prestito dei seguenti volumi sta per scadere:

<<items.content>>

<<branches.branchname>>', 'email'),
('circulation','RENEWAL','Rinnovi','Rinnovi','Per le seguenti copie sono stati rinnovati i prestiti:\r\n----\r\n<<
biblio.title>>\r\n----\r\nGrazie per aver visitaro <<branches.branchname>>.', 'email'),
('reserves', 'HOLD', 'Prenotazione disponibile per il ritiro', 'Prenotazione disponibile per il ritiro a <<branches.branchname>>', 'Salve <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nHai una prenotazione disponibile per il ritiro fino al <<reserves.waitingdate>>:\r\n\r\nTitolo: <<biblio.title>>\r\nAutore: <<biblio.author>>\r\nCopia n. : <<items.copynumber>>\r\nPresso: <<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress3>>\r\n<<branches.branchcity>> <<branches.branchzip>>', 'email'),
('reserves', 'HOLD', 'Prenotazione disponibile per il ritiro (stampa)', 'Prenotazione disponibile per il ritiro (stampa)', '<<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n\r\n\r\nPrenotazione disponibile per il ritiro\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>>\r\n<<borrowers.address>>\r\n<<borrowers.city>> <<borrowers.zipcode>>\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>> <<borrowers.cardnumber>>\r\n\r\nHai una prenotazione disponibile per il ritiro fino al <<reserves.waitingdate>>:\r\n\r\nTitolo: <<biblio.title>>\r\nAutore: <<biblio.author>>\r\nCopia n. : <<items.copynumber>>\r\n', 'print'),
('circulation','CHECKIN','Restituzione (Digest)','Restituzione','Questi prestiti sono stati restituiti:\r\n----\r\n[% biblio.title %]\r\n----\r\nGrazie.', 'email'),
('circulation','CHECKOUT','Prestiti','Prestiti','Ti sono stati dati in prestito:\r\n----\r\n[% biblio.title %]\r\n----\r\nGrazie da parte di [% branch.branchname %].', 'email'),
('reserves', 'HOLDPLACED', 'Prenotazione di una copia', 'Prenotazione di una copia','Una prenotazione è stata fatta su una copia di : <<biblio.title>> (<<biblio.biblionumber>>) dall\'utente <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>).', 'email'),
('reserves', 'CANCEL_HOLD_ON_LOST', 'Hold has been cancelled', "Hold has been cancelled", "Dear [% borrower.firstname %] [% borrower.surname %],\n\nWe regret to inform you, that the following item can not be provided due to it being missing. Your hold was cancelled.\n\nTitle: [% biblio.title %]\nAuthor: [% biblio.author %]\nCopy: [% item.copynumber %]\nLocation: [% branch.branchname %]", 'email'),
('suggestions','ACCEPTED','Suggerimento d\'acquisto accettato', 'Suggerimento d\'acquisto accettato','Salve <<borrowers.firstname>> <<borrowers.surname>>,\n\nHai suggerito di acquistare <<suggestions.title>> di <<suggestions.author>>.\n\nLa biblioteca ha revisionato il suggerimento oggi. La copia verrà ordinato il più presto possibile. Riceverai un\'email quando l\'ordine sarà completato e una altra mail quanto arriverà in biblioteca.\n\nSe hai domande, scrivici pure all\' email <<branches.branchemail>>.\n\nGrazie di tutto,\n\n<<branches.branchname>>', 'email'),
('suggestions','AVAILABLE','Suggerimento d\'acquisto disponibile', 'Suggerimento d\'acquisto disponibile','Salve <<borrowers.firstname>> <<borrowers.surname>>,\n\nHai suggerito di acquistare <<suggestions.title>> di <<suggestions.author>>.\n\nTi informiamo che la copia è arrivata in biblioteca.\n\nSe hai domande, scrivici pure all\' email <<branches.branchemail>>.\n\nGrazie di tutto,\n\n<<branches.branchname>>', 'email'),
('suggestions','ORDERED','Suggerimento d\'acquisto ordinato', 'Suggerimento d\'acquisto ordinato','Salve <<borrowers.firstname>> <<borrowers.surname>>,\n\nHai suggerito di acquistare <<suggestions.title>> di <<suggestions.author>>.\n\nTi informiamo che l\'ordine è stata inviato al fornitore della biblioteca. Dovrebbe arrivare in poco tempo, poi verrà aggiunto alla collezione della biblioteca.\n\nRiceverai un\'altra email quando sarà disponibile.\n\nSe hai domande, scrivici pure all\' email <<branches.branchemail>>\n\nGrazie di tutto,\n\n<<branches.branchname>>', 'email'),
('suggestions','REJECTED','Suggerimento d\'acquisto rifiutato', 'Suggerimento d\'acquisto rifiutato','Salve <<borrowers.firstname>> <<borrowers.surname>>,\n\nHai suggerito di acquistare <<suggestions.title>> di <<suggestions.author>>.\n\na biblioteca ha revisionato il suggerimento oggi e ha deciso di non seguire il suggerimento.\n\nLa motivazione è: <<suggestions.reason>>\n\nSe hai domande, scrivici pure all\' email <<branches.branchemail>>.\n\nGrazie di tuttp,\n\n<<branches.branchname>>', 'email'),
('suggestions','TO_PROCESS','Notifica al proprietario del fondo', 'Un suggeerimento è pronto per essere lavorato','Caro bibliotecario <<borrowers.firstname>> <<borrowers.surname>>,\n\n c\'è un nuovo suggerimento pronto per essere lavorato: <<suggestions.title>> by <<suggestions.author>>.\n\n Grazie dell\'attenzione,\n\n<<branches.branchname>>', 'email'),
('suggestions', 'NOTIFY_MANAGER', 'Notify manager of a suggestion', "A suggestion has been assigned to you", "Dear [% borrower.firstname %] [% borrower.surname %],\nA suggestion has been assigned to you: [% suggestion.title %].\nThank you,\n[% branch.branchname %]", 'email'),
('members', 'DISCHARGE', 'Liberatoria', 'Liberatoria per <<borrowers.firstname>> <<borrowers.surname>>', '<h1>Liberatoria</h1>\r\n\r\nLa biblioteca  <<borrowers.branchcode>> certifica che il seguente utente :\r\n\r\n    <<borrowers.firstname>> <<borrowers.surname>>\r\n   Numero tessera : <<borrowers.cardnumber>>\r\n\r\nha restituito tutti i documenti ricevuti.', 'email'),
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
    "<h3><<branches.branchname>></h3>
    Checked in items for <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
    (<<borrowers.cardnumber>>) <br />

    <<today>><br />

    <h4>Checked in today</h4>
    <checkedin>
    <p>
    <<biblio.title>> <br />
    Barcode: <<items.barcode>><br />
    </p>
    </checkedin>",1, 'print');

INSERT INTO letter (module, code, name, title, content, is_html)
VALUES ('circulation','ISSUESLIP','Ricevuta di prestito','Ricevuta di prestito', '<h3><<branches.branchname>></h3>
Prestito a <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(<<borrowers.cardnumber>>) <br />

<<today>><br />

<h4>Prestito</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Codice a barre: <<items.barcode>><br />
Data di scadenza: <<issues.date_due>><br />
</p>
</checkedout>

<h4>Ritardi</h4>
<overdue>
<p>
<<biblio.title>> <br />
Codice a barre: <<items.barcode>><br />
Data di scadenza: <<issues.date_due>><br />
</p>
</overdue>

<hr>

<h4 style="text-align: center; font-style:italic;">Novità</h4>
<news>
<div class="newsitem">
<h5 style="margin-bottom: 1px; margin-top: 1px"><b><<opac_news.title>></b></h5>
<p style="margin-bottom: 1px; margin-top: 1px"><<opac_news.content>></p>
<p class="newsfooter" style="font-size: 8pt; font-style:italic; margin-bottom: 1px; margin-top: 1px">Inserite il <<opac_news.published_on>></p>
<hr />
</div>
</news>', 1),
('circulation','ISSUEQSLIP','Ricevuta (sintetica)','Ricevuta (sintetica)', '<h3><<branches.branchname>></h3>
Prestato/i a <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(<<borrowers.cardnumber>>) <br />

<<today>><br />

<h4>Prestati oggi</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Codice a barre: <<items.barcode>><br />
Data di scadenza: <<issues.date_due>><br />
</p>
</checkedout>', 1),
('circulation','HOLD_SLIP','Ricevuta (prenotazione)','Ricevuta (prenotazione)', '<h5>Data: <<today>></h5>

<h3> Trasferita a/Prenotata in <<branches.branchname>></h3>

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
<h3>Opere prenotate</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
   <li><<reserves.waitingdate>></li>
</ul>
<p>Note:
<pre><<reserves.reservenotes>></pre>
</p>
', 1),
('circulation','TRANSFERSLIP','Ricevuta (trasferimento)','Ricevuta (trasferimento)', '<h5>Data: <<today>></h5>

<h3>Transferita a<<branches.branchname>></h3>

<h3>Opera</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
</ul>', 1);
INSERT INTO `letter` (`module`,`code`,`branchcode`,`name`,`is_html`,`title`,`content`)
VALUES (
'members',  'OPAC_REG_VERIFY',  '',  'Email di verifica dell\'autoregistrazione',  '1',  'Verifica la tua autoregistrazione',  'Ciao!

Sei stato registrato tra gli utenti della biblioteca. Per favore verifica il tuo email cliccando questo link per finire il processo.

<<OPACBaseURL>>/cgi-bin/koha/opac-registration-verify.pl?token=<<borrower_modifications.verification_token>>

Se non hai fatto tu la richiesta, puoi ignorare questo messaggio. La richciesta scadrà in posco tempo.'
);

INSERT INTO  letter (module, code, branchcode, name, is_html, title, content)
VALUES ('members', 'SHARE_INVITE', '', 'Invito per condividere una lista', '0', 'Condivisione lista <<listname>>', 'Salve,

Uno degli utenti della biblioteca, <<borrowers.firstname>> <<borrowers.surname>>, ti invita condividere una lista <<listname>> all\'interno dell\'Opac.

Per accedere a questa lista clicca sull\'URL che segue o copia-incolla l\'URL nel tuo browser.

<<shareurl>>

Nel caso tu non sia registrato nella biblioteca o non voglia accettare quest\'invito, allora ignora questa email. Nota anche che l\'invito scade in 2 settimane.

Grazie di tutto

Lo staff della biblioteca.'
);
INSERT INTO  letter (module, code, branchcode, name, is_html, title, content)
VALUES ( 'members', 'SHARE_ACCEPT', '', 'Notifica di condivisione lista accetata', '0', 'Condivisione alla lista <<listname>> accettata', 'Salve,

Ti informiamo che l\'utente <<borrowers.firstname>> <<borrowers.surname>> ha accettato il tuo invito a condividere la tua lista <<listname>> .

Grazie di tutto

Lo staff della biblioteca.'
);

INSERT INTO letter(module, code, branchcode, name, title, content, message_transport_type)
VALUES ('acquisition', 'ACQ_NOTIF_ON_RECEIV', '', 'Notifica alla ricezione', 'Ordine ricevutod', 'Caro <<borrowers.firstname>> <<borrowers.surname>>,\n\n L\' ordine <<aqorders.ordernumber>> (<<biblio.title>>) è stato ricevuto.\n\nLa tua biblioteca.', 'email'),
('members','MEMBERSHIP_EXPIRY','','Account in scadenza','La tessera sta per scadere','Caro <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>,.\r\n\r\nLa tessera della biblioteca scadrà tra poco, il: :\r\n\r\n<<borrowers.dateexpiry>>\r\n\r\nGrazie dell\' attenzione,\r\n\r\n<<branches.branchname>>','email');

INSERT INTO letter ( module, code, branchcode, name, is_html, title, content, message_transport_type )
VALUES ( 'circulation', 'OVERDUES_SLIP', '', 'Ritardi (ricevuta)', '0', 'Ricevuta dei ritard', 'Le seguenti copie sono in ritardo:

<item>"<<biblio.title>>" di <<biblio.author>>, <<items.itemcallnumber>>, Barcode: <<items.barcode>> Multa: <<items.fine>></item>
', 'print' );

INSERT INTO `letter` (module, code, branchcode, name, is_html, title, content, message_transport_type)
VALUES ('members','PASSWORD_RESET','','Nuova password',1,'Nuova password','<html>\r\n<p>Questa email ti è stata mandata come risposta allaa tua richiesta di recupero pssword per l\'utente <strong><<user>></strong>.\r\n</p>\r\n<p>\r\nPuoi ora creare una nuova password usando questo link:\r\n<br/><a href=\"<<passwordreseturl>>\"><<passwordreseturl>></a>\r\n</p>\r\n<p>Queso link rimarrà valido per 2 giorni dalla ricezione dell\' email, successivamente dovrai rifare la procedura se non cambi la tua password.</p>\r\n<p>Grazie.</p>\r\n</html>\r\n','email'
);

INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
('circulation', 'AR_CANCELED', '', 'Richiesta articolo - cancellato', 0, 'La richiesta di un articolo è stata cancellata', 'Salve <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>),\r\n\r\nLa tua richiesta di un articolo da <<biblio.title>> (<<items.barcode>>) è stata cancellata per la seguente ragione:\r\n\r\n<<article_requests.notes>>\r\n\r\nL\'articolo richiesto:\r\nTitolo: <<article_requests.title>>\r\nAutore: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nFascicolo: <<article_requests.issue>>\r\nData: <<article_requests.date>>\r\nPagine: <<article_requests.pages>>\r\nChapitoli: <<article_requests.chapters>>\r\nNote: <<article_requests.patron_notes>>\r\n\r\nLa tua biblioteca', 'email'),
('circulation', 'AR_COMPLETED', '', 'Richiesta articolo - arrivato', 0, 'L\'articolo richiesto è arrivato', 'Salve <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>),\r\n\r\nAbbiamo completato la tua tichiesta di un articolo di <<biblio.title>> (<<items.barcode>>).\r\n\r\nL\'articolo richiesto:\r\nTitolo: <<article_requests.title>>\r\nAutore: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nFascicolo: <<article_requests.issue>>\r\nData: <<article_requests.date>>\r\nPagine: <<article_requests.pages>>\r\nChapitoli: <<article_requests.chapters>>\r\nNote: <<article_requests.patron_notes>>\r\n\r\nPuoi ritirare l\'articolo presso: <<branches.branchname>>.\r\n\r\nSalve!', 'email'),
('circulation', 'AR_PENDING', '', 'Richiesta articolo - ricevuta', 0, 'Ricevuto la richiesta di un articolo', 'Salve <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nAbbiamo ricevuto la tua richiesta di un articolo di <<biblio.title>> (<<items.barcode>>).\r\n\r\nL\'articolo richiesto:\r\nTitolo: <<article_requests.title>>\r\nAutore: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nFascicolo: <<article_requests.issue>>\r\nData: <<article_requests.date>>\r\nPagine: <<article_requests.pages>>\r\nChapitoli: <<article_requests.chapters>>\r\nNote: <<article_requests.patron_notes>>\r\n\r\nGrazie!', 'email'),
('circulation', 'AR_SLIP', '', 'Richiesta articolo - ricevuta a stampa', 0, 'Richiesta articolo', 'Richiesta articolo\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>),\r\n\r\nTitolo: <<biblio.title>>\r\nBarcode: <<items.barcode>>\r\n\r\nArticolo rechiesto:\r\nTitle: <<article_requests.title>>\r\nAutore: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nFascicolo: <<article_requests.issue>>\r\nData: <<article_requests.date>>\r\nPagine: <<article_requests.pages>>\r\nChapitoli: <<article_requests.chapters>>\r\nNote: <<article_requests.patron_notes>>\r\n', 'print'),
('circulation', 'AR_PROCESSING', '', 'Richiesta articolo - in lavorazione', 0, 'La richiesta di un articolo è in lavorazione', 'Salve <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>),\r\n\r\nStiamo ora lavorando la tua richiesta di un articolo da <<biblio.title>> (<<items.barcode>>).\r\n\r\nL\'articolo richiesto:\r\nTitolo: <<article_requests.title>>\r\nAutore: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nFascicolo: <<article_requests.issue>>\r\nData: <<article_requests.date>>\r\nPagine: <<article_requests.pages>>\r\nChapitoli: <<article_requests.chapters>>\r\nNote: <<article_requests.patron_notes>>\r\n\r\nGrazie!', 'email'),
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
('circulation', 'SR_SLIP', '', 'Stock Rotation Slip', 0, 'Stockrotation Report', 'Stockrotation report for [% branch.name %]:\r\n\r\n[% IF branch.items.size %][% branch.items.size %] items to be processed for this branch.\r\n[% ELSE %]No items to be processed for this branch\r\n[% END %][% FOREACH item IN branch.items %][% IF item.reason != \'in-demand\' %]Title: [% item.title %]\r\nAuthor: [% item.author %]\r\nCallnumber: [% item.callnumber %]\r\nLocation: [% item.location %]\r\nBarcode: [% item.barcode %]\r\nOn loan?: [% item.onloan %]\r\nStatus: [% item.reason %]\r\nCurrent Library: [% item.branch.branchname %] [% item.branch.branchcode %]\r\n\r\n[% END %][% END %]', 'email');

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
