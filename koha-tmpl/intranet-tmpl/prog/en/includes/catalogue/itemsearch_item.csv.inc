[%- USE Branches -%]
[%- USE Koha -%]
[%- biblio = item.biblio | html -%]
[%- biblioitem = item.biblioitem | html -%]
"[% biblio.title | html %] [% IF ( Koha.Preference( 'marcflavour' ) == 'UNIMARC' && biblio.author ) %]by [% END %][% biblio.author | html %]", "[% (biblioitem.publicationyear || biblio.copyrightdate) | html %]", "[% biblioitem.publishercode | html %]", "[% biblioitem.collectiontitle | html %]", "[% item.barcode | html %]", "[% item.itemcallnumber | html %]", "[% Branches.GetName(item.homebranch) | html %]", "[% Branches.GetName(item.holdingbranch) | html %]", "[% item.location | html %]", "[% item.stocknumber | html %]", "[% item.status | html %]", "[% (item.issues || 0) | html %]"
