[%# Input params:
    bib - search result biblio record
%]
[% IF OpenLibrarySearch && (
        bib.normalized_isbn ||
        bib.lccn ||
        bib.normalized_oclc
) %]
    <div class="ol_readapi_book" isbn="[% bib.normalized_isbn %]" lccn="[% bib.lccn %]" oclc="[% bib.normalized_oclc %]">Open Library: </div>
[% END %]
