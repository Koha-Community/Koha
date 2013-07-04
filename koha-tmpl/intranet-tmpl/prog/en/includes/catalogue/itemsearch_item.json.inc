[%- USE Branches -%]
[%- biblio = item.biblio -%]
[%- biblioitem = item.biblioitem -%]
[
  "<a href='/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblio.biblionumber %]' title='Go to record detail page'>[% biblio.title |html %]</a> by [% biblio.author |html %]",
  "[% biblioitem.publicationyear |html %]",
  "[% biblioitem.publishercode |html %]",
  "[% biblioitem.collectiontitle |html %]",
  "<a href='/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=[% biblio.biblionumber %]#item[% item.itemnumber %]' title='Go to item details'>[% item.barcode |html %]</a>",
  "[% item.itemcallnumber |html %]",
  "[% Branches.GetName(item.homebranch) |html %]",
  "[% Branches.GetName(item.holdingbranch) |html %]",
  "[% item.location |html %]",
  "[% item.stocknumber |html %]",
  "[% item.status |html %]",
  "[% (item.issues || 0) |html %]",
  "<a href='/cgi-bin/koha/cataloguing/additem.pl?op=edititem&biblionumber=[% item.biblionumber %]&itemnumber=[% item.itemnumber %]'>Modify</a>"
]
