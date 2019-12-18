$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO export_format( profile, description, content, csv_separator, type, used_for ) VALUES
        ("Late orders (csv profile)", "default CSV export for late orders", 'Title[% separator %]Author[% separator %]Publication year[% separator %]ISBN[% separator %]Quantity[% separator %]Number of claims
        [% FOR order IN orders ~%]
        [%~ SET biblio = order.biblio ~%]
        "[% biblio.title %]"[% separator ~%]
        "[% biblio.author %]"[% separator ~%]
        "[% bibio.biblioitem.publicationyear %]"[% separator ~%]
        "[% biblio.biblioitem.isbn %]"[% separator ~%]
        "[% order.quantity%]"[% separator ~%]
        "[% order.claims.count%][% IF order.claims.count %]([% FOR c IN order.claims %][% c.claimed_on | $KohaDates %][% UNLESS loop.last %], [% END %][% END %])[% END %]"
        [% END %]', ",", "sql", "late_orders")
    });
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24163 - Define a default CSV profile for late orders)\n";
}
