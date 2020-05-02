INSERT IGNORE INTO export_format( profile, description, content, csv_separator, type, used_for )
VALUES ( "issues to claim", "CSV export per fascicoli in ritardo", "FORNITORE=aqbooksellers.name|TITOLO=subscription.title|NUMERO FASC=serial.serialseq|IN RITARDO DAL=serial.planneddate", ",", "sql", "late_issues" ),
("Late orders (CSV profile)", "Default CSV export for late orders", 'Title[% separator %]Author[% separator %]Publication year[% separator %]ISBN[% separator %]Quantity[% separator %]Number of claims
[% FOR order IN orders ~%]
[%~ SET biblio = order.biblio ~%]
"[% biblio.title %]"[% separator ~%]
"[% biblio.author %]"[% separator ~%]
"[% bibio.biblioitem.publicationyear %]"[% separator ~%]
"[% biblio.biblioitem.isbn %]"[% separator ~%]
"[% order.quantity%]"[% separator ~%]
"[% order.claims.count%][% IF order.claims.count %]([% FOR c IN order.claims %][% c.claimed_on | $KohaDates %][% UNLESS loop.last %], [% END %][% END %])[% END %]"
[% END %]', ",", "sql", "late_orders");
