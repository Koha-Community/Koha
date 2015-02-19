[% names = CGI.param() %]
[% params = [] %]
[% FOREACH name IN names %]
  [% IF name != 'sortby' AND name != 'sortorder' %]
    [% params.push(name _ "=" _ CGI.param(name)) %]
  [% END %]
[% END %]
[% base_url = "/cgi-bin/koha/catalogue/itemsearch.pl?" _ params.join('&') %]

[% BLOCK itemsearch_header %]
  [% sortorder = 'asc' %]
  [% classes = [] %]
  [% IF CGI.param('sortby') == name %]
    [% classes.push('active') %]
    [% classes.push('sort-' _ CGI.param('sortorder')) %]
    [% IF CGI.param('sortorder') == 'asc' %]
      [% sortorder = 'desc' %]
    [% END %]
  [% END %]
  [% url = base_url _ '&sortby=' _ name _ '&sortorder=' _ sortorder %]
  <th class="[% classes.join(' ') %]">
    <a href="[% url %]" title="Sort on [% label %] ([% sortorder %])">[% text %]</a>
  </th>
[% END %]

<table>
  <thead>
    <tr>
      [% INCLUDE itemsearch_header name='title' label='title' text='Title' %]
      [% INCLUDE itemsearch_header name='publicationyear' label='publication date' text='Publication date' %]
      [% INCLUDE itemsearch_header name='publishercode' label='publisher' text='Publisher' %]
      [% INCLUDE itemsearch_header name='collectiontitle' label='collection' text='Collection' %]
      [% INCLUDE itemsearch_header name='barcode' label='barcode' text='Barcode' %]
      [% INCLUDE itemsearch_header name='itemcallnumber' label='callnumber' text='Call number' %]
      [% INCLUDE itemsearch_header name='homebranch' label='home branch' text='Home library' %]
      [% INCLUDE itemsearch_header name='holdingbranch' label='holding branch' text='Current location' %]
      [% INCLUDE itemsearch_header name='location' label='location' text='Shelving location' %]
      [% INCLUDE itemsearch_header name='stocknumber' label='inventory number' text='Inventory number' %]
      [% INCLUDE itemsearch_header name='notforloan' label='status' text='Status' %]
      [% INCLUDE itemsearch_header name='issues' label='issues' text='Checkouts' %]
      <th></th>
    </tr>
  </thead>
  <tbody>
    [% FOREACH item IN items %]
      [% INCLUDE 'catalogue/itemsearch_item.inc' item = item %]
    [% END %]
  </tbody>
</table>
