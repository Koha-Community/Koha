INSERT IGNORE INTO export_format( profile, description, content, csv_separator, type, used_for )
VALUES ( "Zeitschriftenreklamationen", "Standardprofil für den Export von Heftinformationen für Zeitschriftenreklamationen", "LIEFERANT=aqbooksellers.name|TITEL=subscription.title|HEFTNUMMER=serial.serialseq|VERSPÄTET SEIT=serial.planneddate", ",", "sql", "late_issues" ),
("Verspätete Bestellungen", "CSV-Profil für verspätete Bestellungen", 'Titel[% separator %]Verfasser[% separator %]Jahr[% separator %]ISBN[% separator %]Bestellte Anzahl[% separator %]Anzahl Reklamationen
[% FOR order IN orders ~%]
[%~ SET biblio = order.biblio ~%]
"[% biblio.title %]"[% separator ~%]
"[% biblio.author %]"[% separator ~%]
"[% bibio.biblioitem.publicationyear %]"[% separator ~%]
"[% biblio.biblioitem.isbn %]"[% separator ~%]
"[% order.quantity%]"[% separator ~%]
"[% order.claims.count%][% IF order.claims.count %]([% FOR c IN order.claims %][% c.claimed_on | $KohaDates %][% UNLESS loop.last %], [% END %][% END %])[% END %]"
[% END %]', ",", "sql", "late_orders");
