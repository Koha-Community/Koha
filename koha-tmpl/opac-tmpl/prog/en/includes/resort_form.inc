<option value="relevance">Relevance</option>
<optgroup label="Popularity">
[% IF ( sort_by == "popularity_dsc" ) %]
<option value="popularity_dsc" selected="selected">Popularity (Most to Least)</option>[% ELSE %]
<option value="popularity_dsc">Popularity (Most to Least)</option>
[% END %]
[% IF ( sort_by == "popularity_asc" ) %]
<option value="popularity_asc" selected="selected">Popularity (Least to Most)</option>[% ELSE %]
<option value="popularity_asc">Popularity (Least to Most)</option>
[% END %]
</optgroup>
<optgroup label="Author">
[% IF ( sort_by == "author_az" || sort_by == "author_asc" ) %]
<option value="author_az" selected="selected">Author (A-Z)</option>
[% ELSE %]
<option value="author_az">Author (A-Z)</option>
[% END %]
[% IF ( sort_by == "author_za" || sort_by == "author_dsc" ) %]
<option value="author_za" selected="selected">Author (Z-A)</option>
[% ELSE %]
<option value="author_za">Author (Z-A)</option>
[% END %]
</optgroup>
<optgroup label="Call Number">
[% IF ( sort_by == "call_number_asc" ) %]
<option value="call_number_asc" selected="selected">Call Number (Non-fiction 0-9 to Fiction A-Z)</option>
[% ELSE %]
<option value="call_number_asc">Call Number (Non-fiction 0-9 to Fiction A-Z)</option>
[% END %]
[% IF ( sort_by == "call_number_dsc" ) %]
<option value="call_number_dsc" selected="selected">Call Number (Fiction Z-A to Non-fiction 9-0)</option>
[% ELSE %]
<option value="call_number_dsc">Call Number (Fiction Z-A to Non-fiction 9-0)</option>
[% END %]
</optgroup>
<optgroup label="Dates">
[% IF ( sort_by == "pubdate_dsc" ) %]
<option value="pubdate_dsc" selected="selected">Publication/Copyright Date: Newest to Oldest</option>
[% ELSE %]
<option value="pubdate_dsc">Publication/Copyright Date: Newest to Oldest</option>
[% END %]
[% IF ( sort_by == "pubdate_asc" ) %]
<option value="pubdate_asc" selected="selected">Publication/Copyright Date: Oldest to Newest</option>
[% ELSE %]
<option value="pubdate_asc">Publication/Copyright Date: Oldest to Newest</option>
[% END %]
[% IF ( sort_by == "acqdate_dsc" ) %]
<option value="acqdate_dsc" selected="selected">Acquisition Date: Newest to Oldest</option>
[% ELSE %]
<option value="acqdate_dsc">Acquisition Date: Newest to Oldest</option>
[% END %]
[% IF ( sort_by == "acqdate_asc" ) %]
<option value="acqdate_asc" selected="selected">Acquisition Date: Oldest to Newest</option>
[% ELSE %]
<option value="acqdate_asc">Acquisition Date: Oldest to Newest</option>
[% END %]
</optgroup>
<optgroup label="Title">
[% IF ( sort_by == "title_az" || sort_by == "title_asc" ) %]
<option value="title_az" selected="selected">Title (A-Z)</option>
[% ELSE %]
<option value="title_az">Title (A-Z)</option>
[% END %]
[% IF ( sort_by == "title_za" || sort_by == "title_dsc" ) %]
<option value="title_za" selected="selected">Title (Z-A)</option>
[% ELSE %]
<option value="title_za">Title (Z-A)</option>
[% END %]
</optgroup>

