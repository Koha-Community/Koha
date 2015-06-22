[%- USE Branches -%]
[%- USE Koha -%]
[%- biblio = item.biblio -%]
[%- biblioitem = item.biblioitem -%]
[
  "[% FILTER escape_quotes = replace('"', '\"') ~%]
    <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblio.biblionumber %]" title="Go to record detail page">[% biblio.title %]</a>[% IF ( Koha.Preference( 'marcflavour' ) == 'UNIMARC' && biblio.author ) %] by[% END %] [% biblio.author %]
  [%~ END %]",
  "[% (biblioitem.publicationyear || biblio.copyrightdate) %]",
  "[% biblioitem.publishercode %]",
  "[% biblioitem.collectiontitle %]",
  "[% FILTER escape_quotes ~%]
    <a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=[% biblio.biblionumber %]#item[% item.itemnumber %]" title="Go to item details">[% item.barcode %]</a>
  [%~ END %]",
  "[% item.itemcallnumber %]",
  "[% Branches.GetName(item.homebranch) %]",
  "[% Branches.GetName(item.holdingbranch) %]",
  "[% item.location %]",
  "[% item.stocknumber %]",
  "[% item.status %]",
  "[% (item.issues || 0) %]",
  "[% FILTER escape_quotes ~%]
    <a href="/cgi-bin/koha/cataloguing/additem.pl?op=edititem&biblionumber=[% item.biblionumber %]&itemnumber=[% item.itemnumber %]">Edit</a>
  [%~ END %]"
]
