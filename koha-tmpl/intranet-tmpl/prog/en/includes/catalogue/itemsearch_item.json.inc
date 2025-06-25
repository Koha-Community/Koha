[%- USE Branches -%]
[%- USE Koha -%]
[%- USE KohaDates -%]
[%- USE To -%]
[%- USE ItemTypes -%]
[%- USE AuthorisedValues -%]
[%- biblio = item.biblio -%]
[%- biblioitem = item.biblioitem -%]
[
"[% FILTER escape_quotes = replace('"', '\"') ~%]
    <input type="checkbox" name="itemnumber" value="[% item.itemnumber | html %]" />
[%~ END %]",
"[% FILTER escape_quotes ~%]
    <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblio.biblionumber | uri %]" title="Go to record detail page">[% INCLUDE 'biblio-title.inc' | trim | collapse %]</a
    >[% IF ( Koha.Preference( 'marcflavour' ) == 'UNIMARC' && biblio.author ) %]by[% END %] [% biblio.author | html %]
[%~ END %]",
"[% (biblioitem.publicationyear || biblio.copyrightdate) | html | $To %]", "[% biblioitem.publishercode | html | $To %]",
"[% AuthorisedValues.GetDescriptionByKohaField( kohafield => 'items.ccode', authorised_value => item.ccode ) | html | $To %]",
"[% FILTER escape_quotes ~%]
    <a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=[% biblio.biblionumber | uri %]#item[% item.itemnumber | uri %]" title="Go to item details">[% item.barcode | html | $To %]</a>
[%~ END %]",
"[% item.itemnumber | html %]", "[% item.enumchron | html | $To %]", "[% item.itemcallnumber | html | $To %]", "[% Branches.GetName(item.homebranch) | html %]", "[% Branches.GetName(item.holdingbranch) | html %]",
"[% AuthorisedValues.GetDescriptionByKohaField( frameworkcode => biblio.frameworkcode, kohafield => 'items.location', authorised_value => item.location) | html %]", "[% ItemTypes.GetDescription(item.itype) | html %]",
"[% item.stocknumber | html | $To %]", "[% AuthorisedValues.GetDescriptionByKohaField( frameworkcode => biblio.frameworkcode, kohafield => 'items.notforloan', authorised_value => item.notforloan) | html %]",
"[% AuthorisedValues.GetDescriptionByKohaField( kohafield => 'items.itemlost', authorised_value => item.itemlost ) || "" | html %]",
"[% AuthorisedValues.GetDescriptionByKohaField( kohafield => 'items.withdrawn', authorised_value => item.withdrawn ) || "" | html %]",
"[% AuthorisedValues.GetDescriptionByKohaField( kohafield => 'items.damaged', authorised_value => item.damaged ) || "" | html %]", "[% item.dateaccessioned | $KohaDates %]", "[% (item.issues || 0) | html %]",
"[% item.datelastborrowed | $KohaDates %]", "[% IF item.checkout %][% item.checkout.date_due | $KohaDates %][% END %]",
"[% FILTER escape_quotes ~%]
    <div class="btn-group dropup"
        ><button type="button" class="btn btn-xs btn-default dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false"> <i class="fa-solid fa-pencil" aria-hidden="true"></i> Edit </button>
        <ul class="dropdown-menu dropdown-menu-end">
            [% IF user.can_edit_items_from( item.homebranch ) %]
                <li><a class="dropdown-item" href="/cgi-bin/koha/cataloguing/additem.pl?op=edititem&biblionumber=[% item.biblionumber | uri %]&itemnumber=[% item.itemnumber | uri %]">Edit item</a></li>
            [% END %]
            <li><a class="dropdown-item" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=[% item.biblionumber | html %]">Edit record</a></li>
        </ul>
    </div>
[%~ END %]"
]
