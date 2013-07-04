[%- USE Branches -%]
[%- biblio = item.biblio -%]
[%- biblioitem = item.biblioitem -%]
"[% biblio.title |html %] by [% biblio.author |html %]", "[% biblioitem.publicationyear |html %]", "[% biblioitem.publishercode |html %]", "[% biblioitem.collectiontitle |html %]", "[% item.barcode |html %]", "[% item.itemcallnumber |html %]", "[% Branches.GetName(item.homebranch) |html %]", "[% Branches.GetName(item.holdingbranch) |html %]", "[% item.location |html %]", "[% item.stocknumber |html %]", "[% item.status |html %]", "[% (item.issues || 0) |html %]"
