INSERT INTO `letter` (module, code, name, title, content, message_transport_type)
VALUES ('circulation','ODUE','Myöhästymisilmoitus','Myöhästymisilmoitus','Hyvä asiakkaamme,\n\nSeuraavat lainat ovat erääntyneet ja ne on palautettava tai uusittava viipymättä.\n\n<item> Teos: "<<biblio.title>>"\n Tekijä: <<biblio.author>>\n Nidetunnus: <<items.barcode>>\n Eräpäivä: <<issues.date_due>></item>\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('claimacquisition','ACQCLAIM','Hankinnan reklamointi','Puuttuva aineisto','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\n<order>Tilausnumero <<aqorders.ordernumber>> (<<biblio.title>>) (tilattu <<aqorders.quantity>> kpl) (<<aqorders.listprice>> €/kpl) ei ole saapunut.</order>\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('orderacquisition','ACQORDER','Hankintatilaus','Uusi tilaus','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\nTilattavaa:\r\n\r\n<order>Tilausnumero <<aqorders.ordernumber>> (<<biblio.title>>) (määrä: <<aqorders.quantity>>) (<<aqorders.listprice>> €/kpl).</order>\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('serial','RLIST','Lehtikiertolista','Lehti on nyt saatavilla','Hyvä asiakkaamme,\n\nLehti on nyt saatavilla:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)\r\n\r\nVoitte nyt noutaa lehden luettavaksenne.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('members','ACCTDETAILS','Tilin tiedot - OLETUS','Kirjaston käyttäjätilinne tunnukset.','Hyvä asiakkaamme,\n\nKirjastojärjestelmän uudet tunnuksenne ovat:\r\n\r\nKäyttäjänimi: <<borrowers.userid>>\r\nSalasana: <<borrowers.password>>\r\n\r\nJos teillä on kirjautumisongelmia, olkaa hyvä ja ottakaa yhteyttä kirjastoon.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('circulation','DUE','Niteen eräpäivän muistutus','Muistutus eräpäivästä','Hyvä asiakkaamme,\n\nSeuraavat niteet erääntyvät:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('circulation','DUEDGST','Eräpäivämuistutus','Eräpäivämuistutus','Hyvä asiakkaamme,\n\nSeuraavat teille lainatut teokset erääntyvät tänään:\n\n <<items.content>>\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('circulation','PREDUE','Ennakkoilmoitus eräpäivästä','Ennakkoilmoitus eräpäivästä','Hyvä asiakkaamme,\n\nMuistutamme lähestyvästä eräpäivästä. Pyydämme uusimaan tai palauttamaan seuraava(t) laina(t) viimeistään eräpäivänä.\n\n <<items.content>>\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('circulation','PREDUEDGST','Ennakkoilmoitus eräpäivästä','Ennakkoilmoitus eräpäivästä','Hyvä asiakkaamme,\n\nMuistutamme lähestyvästä eräpäivästä. Pyydämme uusimaan tai palauttamaan seuraava(t) laina(t) viimeistään eräpäivänä.\n\n <<items.content>>\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('circulation','RENEWAL','Lainanne on uusittu','Lainanne on uusittu','Hyvä asiakkaamme,\n\nSeuraavat lainanne on uusittu:\n\nTeos: "<<biblio.title>>"\nTekijä: <<biblio.author>>\nNidetunnus: <<items.barcode>>\nEräpäivä: <<issues.date_due>>\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('reserves', 'HOLD', 'Saapumisilmoitus', 'Saapumisilmoitus', 'Hyvä asiakkaamme,\n\nSeuraava varaamasi aineisto on saapunut. Voit noutaa kirjat palveluaikoina viimeistään varauksen raukeamispäivänä.\n\n Kirjasto: <<branches.branchname>> Tekijä: <<biblio.author>>\n Teos: <<biblio.title>>\n Nidetunnus: <<items.barcode>>\n Raukeamispäivä: <<reserves.expirationdate>>\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('reserves', 'HOLD', 'Saapumisilmoitus', 'Saapumisilmoitus', 'Hyvä asiakkaamme,\n\nSeuraava varaamasi aineisto on saapunut. Voit noutaa kirjat palveluaikoina viimeistään varauksen raukeamispäivänä.\n\n Kirjasto: <<branches.branchname>> Tekijä: <<biblio.author>>\n Teos: <<biblio.title>>\n Nidetunnus: <<items.barcode>>\n Raukeamispäivä: <<reserves.expirationdate>>\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'print'),
('circulation','CHECKIN','Palautuskuitti','Palautitte niteet', 'Hyvä asiakkaamme,\n\nPalautitte seuraavat niteet:\n----\n Teos: "<<biblio.title>>"\n Tekijä: <<biblio.author>>\n Nidetunnus: <<items.barcode>>\n----\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('circulation','CHECKOUT','Lainauskuitti','Uusi lainaus', 'Hyvä asiakkaamme,\n\nLainasit seuraavat niteet:\r\n----\r\n<<biblio.title>>\r\n<<items.barcode>> eräpäivä: <<issues.date_due>>\r\n----\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('reserves', 'HOLDPLACED', 'Varaus nimekkeestä', 'Varauksenne on rekisteröity', 'Hyvä asiakkaamme,\n\nSeuraavasta nimekkeestä on tehty varaus:\n Teos: "<<biblio.title>>"\n Tekijä: <<biblio.author>>\n Järjestelmän sisäinen teostunnus: <<biblio.biblionumber>>.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('reserves', 'CANCEL_HOLD_ON_LOST', 'Varaus on peruttu', "Varaus on peruttu", "Hyvä asiakkaamme,\n\nValitettavasti varaustanne seuraavasta nimekkeestä ei voida täyttää, sillä nide on kadonnut. Varauksenne on peruttu.\n\nTeos: [% biblio.title %]\nTekijä: [% biblio.author %]\nNidenumero: [% item.copynumber %]\nKirjasto: [% branch.branchname %]\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n'", 'email'),
('suggestions','ACCEPTED','Hankintaehdotus hyväksytty', 'Hankintaehdotusenne on hyväksytty','Hyvä asiakkaamme,\n\nOlette tehnyt uuden hankintaehdotuksen teoksesta <<suggestions.title>>, jonka tekijä <<suggestions.author>>.\n\nKirjasto on käsitellyt ehdotuksesi tänään. Nimeke tilataan kirjaston kokoelmaan. Saat sähköpostiviestin, kun tilaus on tehty ja uuden viestin, kun aineisto on saapunut kirjastoon.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('suggestions','AVAILABLE','Hankintaehdotuksesi saatavilla', 'Hankintaehdotuksenne on saatavilla','Hyvä asiakkaamme,\n\nOlette tehneet uuden hankintaehdotuksen teokselle <<suggestions.title>> / <<suggestions.author>>.\n\nTeos on nyt saapunut kirjastoon. Voitte halutessanne tehdä teoksesta nyt varauksen.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('suggestions','ORDERED','Hankintaehdotus tilattu', 'Hankintaehdotuksenne on tilattu','Hyvä asiakkaamme,\n\nOlette tehneet uuden hankintaehdotuksen teokselle <<suggestions.title>> / <<suggestions.author>>.\n\nKirjasto on nyt tehnyt tilauksen teoksesta. Kun se on saapunut kirjastoon, sen käsittely kokoelmaan vie jonkin aikaa. Voitte kuitenkin halutessanne tehdä teoksesta varauksen jo nyt. Saatte vielä uuden viestin, kun teos on saatavilla.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('suggestions','REJECTED','Hankintaehdotus hylätty', 'Hankintaehdotuksenne on hylätty','Hyvä asiakkaamme,\n\nYOlette tehnyt uuden hankintaehdotuksen teoksesta <<suggestions.title>> / <<suggestions.author>>.\n\nKirjasto on käsitellyt ehdotuksenne ja valitettavasti hylännyt sen.\n\nHylkäyksen syy: <<suggestions.reason>>\n\nJos teillä on kysyttävää, laittakaa sähköpostia osoitteeseen <<branches.branchemail>>\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('suggestions','TO_PROCESS','Hankintaehdotus valmis käsiteltäväksi', 'Hankintaehdotus on valmis käsiteltäväksi','Hyvä asiakkaamme,\n\nHankintaehdotus on nyt valmis käsiteltäväksi: <<suggestions.title>> / <<suggestions.author>>.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email');

INSERT INTO `letter` (module, code, name, title, content, is_html, message_transport_type)
VALUES ('members', 'DISCHARGE', 'Velattomuusilmoitus', 'Velattomuusilmoitus asiakkaalle <<borrowers.firstname>> <<borrowers.surname>>', '
<<today>>
<h1>Velattomuusilmoituksen vahvistus</h1>
<p><<branches.branchname>> vahvistaa, että seuraava asiakas:<br>
<<borrowers.firstname>> <<borrowers.surname>> (korttinumero: <<borrowers.cardnumber>>)<br>
on palauttanut kaikki lainansa.</p>

<<branches.branchname>>
<<branches.branchaddress1>> <<branches.branchaddress2>> <<branches.branchaddress3>>
Puhelin: <<branches.branchphone>>
Sähköposti: <<branches.branchemail>>', 1, 'email');

INSERT INTO `letter` (module, code, name, title, content, is_html)
VALUES ('circulation','ISSUESLIP','Lainauskuitti, kaikki lainat','Tänään lainatut', '<h3><<branches.branchname>></h3>

<<today>><br />

<h4>Lainatut</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Nidetunnus: <<items.barcode>><br />
Eräpäivä: <<issues.date_due>><br />
</p>
</checkedout>

<h4>Myöhässä olevat</h4>
<overdue>
<p>
<<biblio.title>> <br />
Nidetunnus: <<items.barcode>><br />
Eräpäivä: <<issues.date_due>><br />
</p>
</overdue>

<hr>

<h4 style="text-align: center; font-style:italic;">Uutiset</h4>
<news>
<div class="newsitem">
<h5 style="margin-bottom: 1px; margin-top: 1px"><b><<opac_news.title>></b></h5>
<p style="margin-bottom: 1px; margin-top: 1px"><<opac_news.content>></p>
<p class="newsfooter" style="font-size: 8pt; font-style:italic; margin-bottom: 1px; margin-top: 1px"><<opac_news.timestamp>></p>
<hr />
</div>
</news>

<<branches.branchname>>
<<branches.branchaddress1>> <<branches.branchaddress2>> <<branches.branchaddress3>>
Puhelin: <<branches.branchphone>>
Sähköposti: <<branches.branchemail>>', 1),
('circulation','ISSUEQSLIP','Pikakuitti','Pikakuitti', '<h3><<branches.branchname>></h3>

<<today>><br />

<h4>Lainattu tänään</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Nidetunnus: <<items.barcode>><br />
Eräpäivä: <<issues.date_due>><br />
</p>
</checkedout>', 1),
('circulation','HOLD_SLIP','Varaus asiakkaalle','Varaus asiakkaalle', '<h3> Varaus kirjastossa <<branches.branchname>></h3>
<h4><<reserves.reservenotes>></h4>
<h3>noudettava: <<reserves.expirationdate>></h3>

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
<h3>VARATTU NIDE</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
   <li><<reserves.waitingdate>></li>
</ul>
<p>Huomautukset:
<pre><<reserves.reservenotes>></pre>
</p>
Päiväys: <<today>>
', 1),
('circulation','TRANSFERSLIP','Kuljetuskuitti','Kuljetuskuitti', '<h2>Kuljeta tänne: <<branches.branchname>></h2>
<h3>Päiväys: <<today>></h3>

<h4>NIDE</h4>
<h3><<biblio.author>></h3>
<h3><<biblio.title>></h3>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
</ul>

<<branches.branchname>>
<<branches.branchaddress1>> <<branches.branchaddress2>> <<branches.branchaddress3>>
Puhelin: <<branches.branchphone>>
Sähköposti: <<branches.branchemail>>' , 1);

INSERT INTO `letter` (`module`,`code`,`branchcode`,`name`,`is_html`,`title`,`content`)
VALUES (
'members',  'OPAC_REG_VERIFY',  '',  'Opac-rekisteröitymisen sähköpostivahvistus',  '1',  'Vahvista kirjaston käyttäjätunnuksesi',  'Hei!

Kirjaston käyttäjätunnuksesi on luoto. Rekisteröitymisen viimeistelemiseksi vahvista vielä sähköpostiosoitteesi klikkaamalla alla olevaa linkkiä:

<<OPACBaseURL>>/cgi-bin/koha/opac-registration-verify.pl?token=<<borrower_modifications.verification_token>>

Jos ette ole pyytänyt käyttäjätilin luomista, voitte jättää tämän viestin huomiotta. Pyyntö vanhenee pian.'
);

INSERT INTO  letter (module, code, branchcode, name, is_html, title, content)
VALUES ('members', 'SHARE_INVITE', '', 'Kutsu listan jakamiseen', '0', 'Jaettu lista <<listname>>', 'Hyvä asiakkaamme,

Asiakkaamme <<borrowers.firstname>> <<borrowers.surname>> haluaa jakaa listan nimeltä <<listname>> verkkokirjastossamme.

Nähdäksesi listan, paina alla olevaa linkkiä tai kopioi se nettiselaimeesi.

<<shareurl>>

Jos ette ole kirjastomme asiakas tai ette halua vastaanottaa listaa, voitte jättää tämän viestin huomiotta. Pyyntö vanhenee kahden viikon kuluessa.'
);
INSERT INTO  letter (module, code, branchcode, name, is_html, title, content)
VALUES ( 'members', 'SHARE_ACCEPT', '', 'Listan jakaminen hyväksytty', '0', 'Listan <<listname>> jako hyväksytty', 'Hyvä asiakkaamme,

Asiakkaamme <<borrowers.firstname>> <<borrowers.surname>> on hyväksynyt kutsunne jakaa lista nimeltä <<listname>> verkkokirjastossamme.'
);

INSERT INTO letter(module, code, branchcode, name, title, content, message_transport_type)
VALUES ('acquisition', 'ACQ_NOTIF_ON_RECEIV', '', 'Tilaus vastaanotettu', 'Tilaus vastaanotettu', 'Hyvä <<borrowers.firstname>> <<borrowers.surname>>,\n\n Tilausnumero <<aqorders.ordernumber>> (<<biblio.title>>) on vastaanotettu.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('members','MEMBERSHIP_EXPIRY','','Kirjastokortti vanhentumassa','Kirjastokorttinne on vanhentumassa','Hyvä asiakkaamme,\r\n\r\nKirjastokorttinne vanhentuu pian. Vanhenemispäivämäärä on:\r\n\r\n<<borrowers.dateexpiry>>\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n','email');

INSERT INTO letter ( module, code, branchcode, name, is_html, title, content, message_transport_type )
VALUES ( 'circulation', 'OVERDUES_SLIP', '', 'Myöhästymiskuitti', '0', 'OVERDUES_SLIP', 'The following item(s) is/are currently overdue:

<item>"<<biblio.title>>" by <<biblio.author>>, <<items.itemcallnumber>>, Barcode: <<items.barcode>> Fine: <<items.fine>></item>
', 'print' );

INSERT INTO `letter` (module, code, branchcode, name, is_html, title, content, message_transport_type)
VALUES ('members','PASSWORD_RESET','','Salasanan resetointi',1,'Kirjaston käyttäjätunnuksen salasanan resetointi','<html>\r\n<p>Tämä sähköposti on lähetetty käyttäjätunnuksen <strong><<user>></strong> salasanan resetointia varten.\r\n</p>\r\n<p>\r\nVoitte vaihtaa salasananne osoitteessa:\r\n<br/><a href=\"<<passwordreseturl>>\"><<passwordreseturl>></a>\r\n</p>\r\n<p>Tämä linkki on voimassa kaksi päivää. Jos ette vaihda salasanaanne tähän mennessä, joudutte pyytämään salasanan resetointia uudestaan.</p>\r\n<p>Kiitos</p>\r\n</html>\r\n','email'
);

INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
('circulation', 'AR_CANCELED', '', 'Artikkelipyyntö - peruttu', 0, 'Artikkelipyyntö on peruttu', 'Hyvä asiakkaamme,\r\n\r\nArtikkelipyyntönne teoksesta <<biblio.title>> (<<items.barcode>>) on peruttu seuraavasta syystä:\r\n\r\n<<article_requests.notes>>\r\n\r\nPyydetty artikkeli:\r\nTeos: <<article_requests.title>>\r\nTekijä: <<article_requests.author>>\r\nVuosikerta: <<article_requests.volume>>\r\Lehti: <<article_requests.issue>>\r\nPäivämäärä: <<article_requests.date>>\r\nSivuja: <<article_requests.pages>>\r\nKappaleita: <<article_requests.chapters>>\r\nHuomioitavaa: <<article_requests.patron_notes>>\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('circulation', 'AR_COMPLETED', '', 'Artikkelipyyntö - suoritettu', 0, 'Artikkelipyyntö on suoritettu', 'Hyvä asiakkaamme,\r\n\r\nOlemme suorittaneet artikkelipyynnön teoksesta <<biblio.title>> (<<items.barcode>>).\r\n\r\nPyydetty artikkeli:\r\nTeos: <<article_requests.title>>\r\nTekijä: <<article_requests.author>>\r\nVuosikerta: <<article_requests.volume>>\r\nLehti: <<article_requests.issue>>\r\nPäivämäärä: <<article_requests.date>>\r\nSivuja: <<article_requests.pages>>\r\nKappaleita: <<article_requests.chapters>>\r\nHuomioitavaa: <<article_requests.patron_notes>>\r\n\r\nVoitte noutaa artikkelin kirjastosta <<branches.branchname>>.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('circulation', 'AR_PENDING', '', 'Artikkelipyyntö - avoinna', 0, 'Artikkelipyyntö vastaanotettu', 'Hyvä asiakkaamme,\r\n\r\nOlemme vastaanottaneet artikkelipyynnön teoksesta <<biblio.title>> (<<items.barcode>>).\r\n\r\nPyydetty artikkeli:\r\nTeos: <<article_requests.title>>\r\nTekijä: <<article_requests.author>>\r\nVuosikerta: <<article_requests.volume>>\r\nLehti: <<article_requests.issue>>\r\nPäivämäärä: <<article_requests.date>>\r\nSivuja: <<article_requests.pages>>\r\nKappaleita: <<article_requests.chapters>>\r\nHuomioitavaa: <<article_requests.patron_notes>>\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('circulation', 'AR_SLIP', '', 'Artikkelipyyntö - kuitti', 0, 'Artikkelipyyntö', 'Artikkelipyyntö:\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>),\r\n\r\nTeos: <<biblio.title>>\r\nViivakoodi: <<items.barcode>>\r\n\r\nPyydetty artikkeli:\r\nTeos: <<article_requests.title>>\r\nTekijä: <<article_requests.author>>\r\nVuosikerta: <<article_requests.volume>>\r\nLehti: <<article_requests.issue>>\r\nPäivämäärä: <<article_requests.date>>\r\nSivuja: <<article_requests.pages>>\r\nKappaleita: <<article_requests.chapters>>\r\nHuomioitavaa: <<article_requests.patron_notes>>\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'print'),
('circulation', 'AR_PROCESSING', '', 'Artikkelipyyntö - käsiteltävänä', 0, 'Artikkelipyyntö on käsiteltävänä', 'Hyvä asiakkaamme,\r\n\r\nKäsittelemme nyt artikkelipyyntöänne teoksesta <<biblio.title>> (<<items.barcode>>).\r\n\r\nPyydetty artikkeli:\r\nTeos: <<article_requests.title>>\r\nTekijä: <<article_requests.author>>\r\nVuosikerta: <<article_requests.volume>>\r\nLehti: <<article_requests.issue>>\r\nPäivämäärä: <<article_requests.date>>\r\nSivuja: <<article_requests.pages>>\r\nKappaleita: <<article_requests.chapters>>\r\nHuomioitavaa: <<article_requests.patron_notes>>\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPuhelin: <<branches.branchphone>>\nSähköposti: <<branches.branchemail>>\n', 'email'),
('circulation', 'CHECKOUT_NOTE', '', 'Asiakkaan lisäämä lainaushuomautus', '0', 'Lainaushuomautus', '<<borrowers.firstname>> <<borrowers.surname>> on lisännyt huomautuksen teokseen <<biblio.title>> - <<biblio.author>> (<<biblio.biblionumber>>).','email');
INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`, `lang`)
    VALUES
        ('circulation', 'ACCOUNT_PAYMENT', '', 'Maksuvahvistus', 0, 'Maksuvahvistus', '[%- USE Price -%]\r\nMaksu, jonka summa on [% credit.amount * -1 | $Price %] on merkitty kirjaston tilillenne.\r\n\r\nTämä maksu koskee seuraavia maksurivejä:\r\n[%- FOREACH o IN offsets %]\r\nKuvaus: [% o.debit.description %]\r\nMaksettu: [% o.amount * -1 | $Price %]\r\nMaksettavaa: [% o.debit.amountoutstanding | $Price %]\r\n[% END %]', 'email', 'default'),
            ('circulation', 'ACCOUNT_WRITEOFF', '', 'Hyvistysvahvistus', 0, 'Hyvitysvahvistus', '[%- USE Price -%]\r\nHyvitys, jonka summa on [% credit.amount * -1 | $Price %] on merkitty kirjaston tilillenne.\r\n\r\nTämä hyvitys koskee seuraavia maksurivejä:\r\n[%- FOREACH o IN offsets %]\r\nKuvaus: [% o.debit.description %]\r\nMaksettu:: [% o.amount * -1 | $Price %]\r\nMaksettavaa: [% o.debit.amountoutstanding | $Price %]\r\n[% END %]', 'email', 'default');
INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
('circulation', 'SR_SLIP', '', 'Varastonkiertokuitti', 0, 'Varastonkiertoraportti', 'Varastonkiertoraportti kirjastolle [% branch.name %]:\r\n\r\n[% IF branch.items.size %][% branch.items.size %] nidettä käsiteltävänä tässä kirjastossa.\r\n[% ELSE %]Ei niteitä käsiteltävänä tässä kirjastossa\r\n[% END %][% FOREACH item IN branch.items %][% IF item.reason != \'in-demand\' %]Teos: [% item.title %]\r\nTekijä: [% item.author %]\r\nLuokka: [% item.callnumber %]\r\nHyllypaikka: [% item.location %]\r\nViivakoodi: [% item.barcode %]\r\nLainassa?: [% item.onloan %]\r\nTila: [% item.reason %]\r\nSijaintikirjasto: [% item.branch.branchname %] [% item.branch.branchcode %]\r\n\r\n[% END %][% END %]', 'email');
