<option value="relevance">Relevance</option>

<optgroup label="Popularity">
	
	[% IF ( sort_by == "popularity_dsc" ) %]
<option value="popularity_dsc" selected="selected">Popularity (most to least)</option>
[% ELSE %]
    <option value="popularity_dsc">Popularity (most to least)</option>
 [% END %]
[% IF ( sort_by == "popularity_asc" ) %]
<option value="popularity_asc" selected="selected">Popularity (least to most)</option>
[% ELSE %]
    <option value="popularity_asc">Popularity (least to most)</option>
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
<option value="call_number_asc" selected="selected">Call Number (0-9 to A-Z)</option>
[% ELSE %]
    <option value="call_number_asc">Call number (0-9 to A-Z)</option>
[% END %]

[% IF ( sort_by == "call_number_dsc" ) %]
<option value="call_number_dsc" selected="selected">Call number (Z-A to 9-0)</option>
[% ELSE %]
    <option value="call_number_dsc">Call number (Z-A to 9-0)</option>
[% END %]

</optgroup>

<optgroup label="Dates">
	[% IF ( sort_by == "pubdate_dsc" ) %]
<option value="pubdate_dsc" selected="selected" >Publication/Copyright date: newest to oldest</option>
	[% ELSE %]
<option value="pubdate_dsc">Publication/Copyright date: newest to oldest</option>
[% END %]

[% IF ( sort_by == "pubdate_asc" ) %]
<option value="pubdate_asc" selected="selected" >Publication/Copyright date: oldest to newest</option>
[% ELSE %]
<option value="pubdate_asc">Publication/Copyright date: oldest to newest</option>
[% END %]

[% IF ( sort_by == "acqdate_dsc" ) %]
<option value="acqdate_dsc" selected="selected">Acquisition date: newest to oldest</option>
[% ELSE %]
<option value="acqdate_dsc">Acquisition date: newest to oldest</option>
 [% END %]

 [% IF ( sort_by == "acqdate_asc" ) %]
<option value="acqdate_asc" selected="selected">Acquisition date: oldest to newest</option>
[% ELSE %]
<option value="acqdate_asc">Acquisition date: oldest to newest</option>
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
