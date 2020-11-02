[%# Input params: bib - search result biblio record %]
[% IF OpenLibrarySearch && ( bib.normalized_isbn || bib.lccn || bib.normalized_oclc ) %]
    <div class="results_summary ol_readapi_book" isbn="[% bib.normalized_isbn | html %]" lccn="[% bib.lccn | html %]" oclc="[% bib.normalized_oclc | html %]" style="display:none"><span class="label">Found in Open Library:</span> </div>
[% END %]
