[%# Input params: bib - search result biblio record %]
[% IF OpenLibrarySearch && ( bib.normalized_isbn || bib.lccn || bib.normalized_oclc ) %]
    <div class="ol_readapi_book" isbn="[% bib.normalized_isbn | html %]" lccn="[% bib.lccn | html %]" oclc="[% bib.normalized_oclc | html %]">Open Library: </div>
[% END %]
