[%- USE Branches -%]
[%- USE Koha -%]
[%- biblio = item.biblio -%]
[%- biblioitem = item.biblioitem -%]
[
  "[% FILTER escape_quotes = replace('"', '\"') ~%]
    <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblio.biblionumber %]" title="Go to record detail page">[% biblio.title |html %]</a>[% IF ( Koha.Preference( 'marcflavour' ) == 'UNIMARC' && biblio.author ) %] by[% END %] [% biblio.author |html %]
  [%~ END %]",
  "[% (biblioitem.publicationyear || biblio.copyrightdate) |html %]",
  "[% biblioitem.publishercode |html %]",
  "[% biblioitem.collectiontitle |html %]",
  "[% FILTER escape_quotes ~%]
    <a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=[% biblio.biblionumber %]#item[% item.itemnumber %]" title="Go to item details">[% item.barcode |html %]</a>
  [%~ END %]",
  "[% item.itemcallnumber |html %]",
  "[% Branches.GetName(item.homebranch) |html %]",
  "[% Branches.GetName(item.holdingbranch) |html %]",
  "[% item.location |html %]",
  "[% item.stocknumber |html %]",
  "[% item.status |html %]",
  "[% (item.issues || 0) |html %]",
  "[% FILTER escape_quotes ~%]
    <a href="/cgi-bin/koha/cataloguing/additem.pl?op=edititem&biblionumber=[% item.biblionumber %]&itemnumber=[% item.itemnumber %]">Edit</a>
  [%~ END %]"
]
