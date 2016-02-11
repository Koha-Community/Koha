[%- USE Branches -%]
[%- USE Koha -%]
[% biblio = item.biblio %]
[% biblioitem = item.biblioitem %]
<tr>
  <td>
    <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblio.biblionumber %]" title="Go to record detail page">[% biblio.title %]</a>
    [% IF ( Koha.Preference( 'marcflavour' ) == 'UNIMARC' && biblio.author ) %] by[% END %] [% biblio.author |html %]
  </td>
  <td>[% biblioitem.publicationyear || biblio.copyrightdate %]</td>
  <td>[% biblioitem.publishercode %]</td>
  <td>[% biblioitem.collectiontitle %]</td>
  <td>
    <a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=[% biblio.biblionumber %]#item[% item.itemnumber %]" title="Go to item details">[% item.barcode %]</a>
  </td>
  <td>[% item.itemcallnumber %]</td>
  <td>[% Branches.GetName(item.homebranch) %]</td>
  <td>[% Branches.GetName(item.holdingbranch) %]</td>
  <td>[% item.location %]</td>
  <td>[% item.stocknumber %]</td>
  <td>[% item.status %]</td>
  <td>[% item.issues || 0 %]</td>
  <td><a href="/cgi-bin/koha/cataloguing/additem.pl?op=edititem&amp;biblionumber=[% item.biblionumber %]&amp;itemnumber=[% item.itemnumber %]">Edit</a></td>
</tr>
