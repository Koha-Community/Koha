use Modern::Perl;

return {
    bug_number => "3150",
    description => "Add LIST and CART notices",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{ INSERT IGNORE INTO letter (module, code, branchcode, name, is_html, title, content, message_transport_type, lang) VALUES
('catalogue','LIST','','Send list',1,'Your list: [% listname | html %]',"[%- USE Branches -%]
[%- USE AuthorisedValues -%]
[%- USE Koha -%]
Hi,<br><br>
[% borrower.firstname | html %] [% borrower.surname | html %] sent you a list from our online catalog called: [% listname | html %].<br>
Please note that the attached file is a MARC bibliographic records file which can be imported into personal bibliographic software like EndNote, Reference Manager or ProCite.<br>
[% IF ( comment ) %]<hr><br>[% comment | html | html_line_break %]<br><br>[% END %]<hr>
<ol>[% FOREACH biblio IN biblios %]<li>
[% biblio.title | html %]
[% IF ( biblio.subtitle ) %][% FOREACH subtitle IN biblio.subtitle.split(' | ') %][% subtitle | html %][% END %][% END %]
[% biblio.part_number | html %] [% biblio.part_name | html %]<br>
[% IF ( biblio.author || biblio.get_marc_contributors.size ) %]Author(s): [% IF ( biblio.author ) %][% biblio.author | html %][% END %][% IF ( biblio.get_marc_contributors ) %][% IF ( biblio.author ) %]; [% END %][% FOREACH author IN biblio.get_marc_contributors %][% FOREACH subfield IN author.MARCAUTHOR_SUBFIELDS_LOOP %][% subfield.separator | html %][% subfield.value | html %][% END %][% UNLESS ( loop.last ) %];[% END %][% END %][% END %]<br>[% END %]
[% SET biblioitem = biblio.biblioitem %][% IF ( biblioitem.isbn ) %]ISBN: [% FOREACH isbn IN biblioitem.isbn %][% isbn | html %][% UNLESS ( loop.last ) %]; [% END %][% END %]<br>[% END %]
[% IF ( biblioitem.publishercode ) %]Published by: [% biblioitem.publishercode | html %][% IF ( biblioitem.publicationyear ) %] in [% biblioitem.publicationyear | html %][% END %][% IF ( biblioitem.pages ) %], [% biblioitem.pages | html %][% END %]<br>[% END %]
[% IF ( biblio.seriestitle ) %]Collection: [% biblio.seriestitle | html %]<br>[% END %]
[% IF ( biblio.copyrightdate ) %]Copyright year: [% biblio.copyrightdate | html %]<br>[% END %]
[% IF ( biblio.notes ) %]Notes: [% biblio.notes | html %]<br>[% END %]
[% IF ( biblio.unititle ) %]Unified title: [% biblio.unititle | html %]<br>[% END %]
[% IF ( biblio.serial ) %]Serial: [% biblio.serial | html %]<br>[% END %]
[% IF ( biblioitem.lccn ) %]LCCN: [% biblioitem.lccn | html %]<br>[% END %]
[% IF ( biblio.get_marc_host ) %]In: [% FOREACH entry IN biblio.get_marc_host %][% entry.title | html %][% IF ( entry.subtitle ) %][% FOREACH subtitle IN entry.subtitle.split(' | ') %][% subtitle | html %][% END %][% END %][% entry.part_number | html %] [% entry.part_name | html %]<br>[% END %][% END %]
[% IF ( biblioitem.url ) %]URL: [% biblioitem.url | html %]<br>[% END %]
<a href='[% Koha.Preference('OpacBaseUrl') %]/cgi-bin/koha/opac-detail.pl?biblionumber=[% biblio.biblionumber | html %]'>View in online catalog</a>
[% IF ( biblio.items.count > 0 ) %]<br>Items: <ul>[% FOREACH item IN biblio.items %]<li>[% Branches.GetName( item.holdingbranch ) | html %]
[% IF ( item.location ) %], [% AuthorisedValues.GetDescriptionByKohaField( kohafield => 'items.location', authorised_value => item.location ) | html %][% END %]
[% IF item.itemcallnumber %]([% item.itemcallnumber | html %])[% END %]
[% item.barcode | html %]</li>[% END %]</ul>[% END %]
<hr></li>[% END %]</ol>", 'email','default' ),
('catalogue','CART','','Send cart',1,'Your cart',"[%- USE Branches -%]
[%- USE AuthorisedValues -%]
[%- USE Koha -%]
Hi,<br><br>
[% borrower.firstname | html %] [% borrower.surname | html %] sent you a cart from our online catalog.<br>
Please note that the attached file is a MARC bibliographic records file which can be imported into personal bibliographic software like EndNote, Reference Manager or ProCite.<br>
[% IF ( comment ) %]<hr><br>[% comment | html | html_line_break %]<br><br>[% END %]<hr>
<ol>[% FOREACH biblio IN biblios %]<li>
[% biblio.title | html %]
[% IF ( biblio.subtitle ) %][% FOREACH subtitle IN biblio.subtitle.split(' | ') %][% subtitle | html %][% END %][% END %]
[% biblio.part_number | html %] [% biblio.part_name | html %]<br>
[% IF ( biblio.author || biblio.get_marc_contributors.size ) %]Author(s): [% IF ( biblio.author ) %][% biblio.author | html %][% END %][% IF ( biblio.get_marc_contributors ) %][% IF ( biblio.author ) %]; [% END %][% FOREACH author IN biblio.get_marc_contributors %][% FOREACH subfield IN author.MARCAUTHOR_SUBFIELDS_LOOP %][% subfield.separator | html %][% subfield.value | html %][% END %][% UNLESS ( loop.last ) %];[% END %][% END %][% END %]<br>[% END %]
[% SET biblioitem = biblio.biblioitem %][% IF ( biblioitem.isbn ) %]ISBN: [% FOREACH isbn IN biblioitem.isbn %][% isbn | html %][% UNLESS ( loop.last ) %]; [% END %][% END %]<br>[% END %]
[% IF ( biblioitem.publishercode ) %]Published by: [% biblioitem.publishercode | html %][% IF ( biblioitem.publicationyear ) %] in [% biblioitem.publicationyear | html %][% END %][% IF ( biblioitem.pages ) %], [% biblioitem.pages | html %][% END %]<br>[% END %]
[% IF ( biblio.seriestitle ) %]Collection: [% biblio.seriestitle | html %]<br>[% END %]
[% IF ( biblio.copyrightdate ) %]Copyright year: [% biblio.copyrightdate | html %]<br>[% END %]
[% IF ( biblio.notes ) %]Notes: [% biblio.notes | html %]<br>[% END %]
[% IF ( biblio.unititle ) %]Unified title: [% biblio.unititle | html %]<br>[% END %]
[% IF ( biblio.serial ) %]Serial: [% biblio.serial | html %]<br>[% END %]
[% IF ( biblioitem.lccn ) %]LCCN: [% biblioitem.lccn | html %]<br>[% END %]
[% IF ( biblio.get_marc_host ) %]In: [% FOREACH entry IN biblio.get_marc_host %][% entry.title | html %][% IF ( entry.subtitle ) %][% FOREACH subtitle IN entry.subtitle.split(' | ') %][% subtitle | html %][% END %][% END %][% entry.part_number | html %] [% entry.part_name | html %]<br>[% END %][% END %]
[% IF ( biblioitem.url ) %]URL: [% biblioitem.url | html %]<br>[% END %]
<a href='[% Koha.Preference('OpacBaseUrl') %]/cgi-bin/koha/opac-detail.pl?biblionumber=[% biblio.biblionumber | html %]'>View in online catalog</a>
[% IF ( biblio.items.count > 0 ) %]<br>Items: <ul>[% FOREACH item IN biblio.items %]<li>[% Branches.GetName( item.holdingbranch ) | html %]
[% IF ( item.location ) %], [% AuthorisedValues.GetDescriptionByKohaField( kohafield => 'items.location', authorised_value => item.location ) | html %][% END %]
[% IF item.itemcallnumber %]([% item.itemcallnumber | html %])[% END %]
[% item.barcode | html %]</li>[% END %]</ul>[% END %]
<hr></li>[% END %]</ol>",'email','default') });

        say $out "Add LIST and CART notices";
    },
};
