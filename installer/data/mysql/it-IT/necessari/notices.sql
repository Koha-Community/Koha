INSERT INTO `letter` (module, code, name, title, content)
VALUES ('circulation','ODUE','Avviso per i ritardi','Copia(e) in ritardo','Caro <<borrowers.firstname>> <<borrowers.surname>>,\n\nci risulta che tu abbia dei ritardi nella restituzione dei prestiti. La tua biblioteca non ti darà una multa per questi ritardi ma ti chiede di rinnovare i prestiti o di restituirli il prima possibile. I dati della biblioteca sono: \n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nTel: <<branches.branchphone>>\nFax: <<branches.branchfax>>\nEmail: <<branches.branchemail>>\n\nSe la biblioteca ti permette di rinnovare online, usa la tua login e password per fare il rinnovo usando l\'opac. Se una copia è in ritardo da più di 30 giorni, sei obbligato a restituirla.\n\nLa seguente copia(e) è(sono) in ritardo:\n\n<item>"<<biblio.title>>" di <<biblio.author>>, <<items.itemcallnumber>>, Barcode: <<items.barcode>> Multa: <<items.fine>></item>\n\nGrazie per l\'attenzione.\n\nIl team della biblioteca <<branches.branchname>>\n'),
('claimacquisition','ACQCLAIM','Sollecito al fornitore','Copia(e) non ricevuta(e)','Gentile <<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\n<order>Il seguente ordine numero <<aqorders.ordernumber>> (<<biblio.title>>) (<<aqorders.quantity>> ordinati) (€<<aqorders.listprice>> ciascuno) non è arrivato in biblioteca.</order>'),
('serial','RLIST','Routing List','Il fascicolo è ora disponibile','Caro <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nIl seguente fascicolo è ora disponibile:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)\r\n\r\nLo trovi presso la tua biblioteca.'),
('members','ACCTDETAILS','Template del messaggio che giunge ai nuovi account','Dettagli del tuo nuovo account in Koha.','Caro <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\nI dettagli del tuo nuovo account in Koha sono:\r\n\r\nUser:  <<borrowers.userid>>\r\nPassword: <<borrowers.password>>\r\n\r\nSe hai qualche problema contatta la biblioteca.\r\n\r\nGrazie dell\'attenzione.\r\n'),
('circulation','DUE','Avviso restituzione (copia singola)','Avviso restituzione','Caro <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nquesta copia è ora da restituire:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)'),
('circulation','DUEDGST','Avviso restituzione (digest)','Avviso restituzione','Hai <<count>> copie da restituire'),
('circulation','PREDUE','Preavviso per le copie da restituire','Avviso copie in scadenza','Caro <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nil prestito per la seguente copia sta per scadere:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)'),
('circulation','PREDUEDGST','Preavviso per le copie da restituire(digest)','Avviso copie in scadenza','Hai <<count>> prestiti che stanno per scadere'),
('circulation','RENEWAL','Rinnovi','Rinnovi','le seguenti copie sono state rinnovate:\r\n----\r\n<<biblio.title>>\r\n----\r\nla biblioteca ti ringrazia.'),
('reserves', 'HOLD', 'Prenotazione disponibile per il ritiro', 'Prenotazione ora disponibile presso <<branches.branchname>>', 'Caro <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nla copia prenotata è a disposizione a partire dal <<reserves.waitingdate>>:\r\n\r\nTitolo: <<biblio.title>>\r\nAutore: <<biblio.author>>\r\nCopia numero: <<items.copynumber>>\r\nla puoi ritirare presso: <<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress3>>\r\n<<branches.branchcity>> <<branches.branchzip>>'),
('reserves', 'HOLD_PRINT', 'Prenotazione disponibile per il ritiro(stampa)', 'Prenotazione disponibile per il ritiro (stampa)', '<<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n\r\n\r\nPrenotazione ora disponibile\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>>\r\n<<borrowers.address>>\r\n<<borrowers.city>> <<borrowers.zipcode>>\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\nCaro <<borrowers.firstname>> <<borrowers.surname>> <<borrowers.cardnumber>>\r\n\r\nHai una prenotazione disponibile dal <<reserves.waitingdate>>:\r\n\r\nTitolo: <<biblio.title>>\r\nAutore: <<biblio.author>>\r\nNumero copia: <<items.copynumber>>\r\n'),
('circulation','CHECKIN','Restituzione (digest)','Restituzioni','Queste copie sono state rese:\r\n----\r\n<<biblio.title>>\r\n----\r\nGrazie.'),
('circulation','CHECKOUT','Prestito (digest)','Prestiti','Queste copie sono state prestate:\r\n----\r\n<<biblio.title>>\r\n----\r\nGrazie della visita.'),
('reserves', 'HOLDPLACED', 'Prenotazione di una copia', 'Prenotazione','Una prenotazione è stata posta sulla seguente copia: <<biblio.title>> (<<biblio.biblionumber>>) dall\'utente <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>).'),
('suggestions','ACCEPTED','Suggerimento d\'acquisto accettato', 'Suggerimento d\'acquisto accettato','Caro <<borrowers.firstname>> <<borrowers.surname>>,\n\nHai suggerito alla biblioteca di acquistare <<suggestions.title>> di <<suggestions.author>>.\n\nLa biblioteca ha esaminato oggi il tuo suggerimento. L\'opera verrà ordinata il prima possibile. Sarai avvisato via email quando l\'ordine verrà completato e di nuovo quando l\'opera arriverà in biblioteca.\n\nSe hai dubbi o domande scrivi a <<branches.branchemail>>.\n\nGrazie di tutto.'),
('suggestions','AVAILABLE','Suggerimento d\'acquisto disponibile', 'L\'opera suggerita è in biblioteca','Caro <<borrowers.firstname>> <<borrowers.surname>>,\n\nl\'opera da te suggerita, <<suggestions.title>> di <<suggestions.author>> è giunta in biblioteca.\n\nSe vuoi puoi contattarci a questo email <<branches.branchemail>>.\n\nGrazie dell\'attenzione.'),
('suggestions','ORDERED','Suggerimento d\'acquisto ordinato', 'Suggerimento d\'acquisto ordinato','Caro <<borrowers.firstname>> <<borrowers.surname>>,\n\nl\'opera da te suggerita, <<suggestions.title>> di <<suggestions.author>>, è stata ordinata.\n\nVerrai avvisato non appena giungerà in biblioteca.\n\nSe vuoi puoi contattarci all\'indirizzo di email <<branches.branchemail>>\n\nGrazie dell\'attenzione.'),
('suggestions','REJECTED','Suggerimento d\'acquisto rifiutato', 'Il suggerimento non è stato accettato','Caro <<borrowers.firstname>> <<borrowers.surname>>,\n\nhai suggerito l\'acquisto dell\'opera: <<suggestions.title>> di <<suggestions.author>>.\n\nLa biblioteca ha esaminato oggi il suggerimento e ha deciso di non procedere all\'acquisto per ora.\n\nLa ragione del rifiuto è: <<suggestions.reason>>\n\nSe vuoi puoi scriverci a questo indirizzo di posta elettronica <<branches.branchemail>>.\n\nGrazie lo stesso dell\'attenzione, lo staff della biblioteca.');
INSERT INTO `letter` (module, code, name, title, content, is_html)
VALUES ('circulation','ISSUESLIP','Ricevuta di prestito','Ricevuta di prestito', '<h3><<branches.branchname>></h3>
Prestito a <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(<<borrowers.cardnumber>>) <br />

<<today>><br />

<h4>Prestito</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Barcode: <<items.barcode>><br />
Data di scadenza: <<issues.date_due>><br />
</p>
</checkedout>

<h4>Scadenze</h4>
<overdue>
<p>
<<biblio.title>> <br />
Barcode: <<items.barcode>><br />
Data di scadenza: <<issues.date_due>><br />
</p>
</overdue>

<hr>

<h4 style="text-align: center; font-style:italic;">News</h4>
<news>
<div class="newsitem">
<h5 style="margin-bottom: 1px; margin-top: 1px"><b><<opac_news.title>></b></h5>
<p style="margin-bottom: 1px; margin-top: 1px"><<opac_news.new>></p>
<p class="newsfooter" style="font-size: 8pt; font-style:italic; margin-bottom: 1px; margin-top: 1px">Posted on <<opac_news.timestamp>></p>
<hr />
</div>
</news>', 1),
('circulation','ISSUEQSLIP','Ricevuta (sintetica)','Ricevuta (sintetica)', '<h3><<branches.branchname>></h3>
Prestito a <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(<<borrowers.cardnumber>>) <br />

<<today>><br />

<h4>Prestiti di oggi</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Barcode: <<items.barcode>><br />
Data di scadenza: <<issues.date_due>><br />
</p>
</checkedout>', 1),
('circulation','RESERVESLIP','Ricevuta (prenotazione)','Ricevuta (prenotazione)', '<h5>Data: <<today>></h5>

<h3> Trasferisci a/Riserva per <<branches.branchname>></h3>

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
<h3>COPIA PRENOTATA</h3>
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

<h3>Trasferisci a <<branches.branchname>></h3>

<h3>COPIA</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
</ul>', 1);

INSERT INTO `letter` (`module`,`code`,`branchcode`,`name`,`is_html`,`title`,`content`)
VALUES (
'members',  'OPAC_REG_VERIFY',  '',  'Email di verifica dell\'autoregistrazione',  '1',  'Verifica il tuo account',  'Ciao!

Il tuo account della biblioteca è stato creato. Seleziona questo link per completare il processo di registrazione:

http://<<OPACBaseURL>>/cgi-bin/koha/opac-registration-verify.pl?token=<<borrower_modifications.verification_token>>

Se non hai inviato questa richiesta, puoi ignorare questo messaggio.'

);
