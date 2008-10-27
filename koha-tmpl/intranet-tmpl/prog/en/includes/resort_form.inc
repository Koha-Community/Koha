<option value="relevance">Relevance</option>

<optgroup label="Popularity">
	
	<!-- TMPL_IF NAME="popularity_dsc" -->
<option value="popularity_dsc" selected="selected">Popularity (Most to Least)</option>
<!-- TMPL_ELSE -->
	<option value="popularity_dsc">Popularity (Most to Least)</option>
 <!-- /TMPL_IF -->
<!-- TMPL_IF NAME="popularity_asc" -->
<option value="popularity_asc" selected="selected">Popularity (Least to Most)</option>
<!-- TMPL_ELSE -->
	<option value="popularity_asc">Popularity (Least to Most)</option>
 <!-- /TMPL_IF -->

</optgroup>

<optgroup label="Author">
	
	<!-- TMPL_IF NAME="author_az" -->
<option value="author_az" selected="selected">Author (A-Z)</option>	
<!-- TMPL_ELSE -->
<option value="author_az">Author (A-Z)</option>
 <!-- /TMPL_IF -->
<!-- TMPL_IF NAME="author_za" -->
<option value="author_za" selected="selected">Author (Z-A)</option>
<!-- TMPL_ELSE -->
<option value="author_za">Author (Z-A)</option>
 <!-- /TMPL_IF -->

</optgroup>

<optgroup label="Call Number">
	
	<!-- TMPL_IF NAME="call_number_asc" -->
<option value="call_number_asc" selected="selected">Call Number (Non-fiction 0-9 to Fiction A-Z)</option>
<!-- TMPL_ELSE -->
	<option value="call_number_asc">Call Number (Non-fiction 0-9 to Fiction A-Z)</option>
<!-- /TMPL_IF -->

<!-- TMPL_IF NAME="call_number_dsc" -->
<option value="call_number_dsc" selected="selected">Call Number (Fiction Z-A to Non-fiction 9-0)</option>
<!-- TMPL_ELSE -->
	<option value="call_number_dsc">Call Number (Fiction Z-A to Non-fiction 9-0)</option>
<!-- /TMPL_IF -->

</optgroup>

<optgroup label="Dates">
	<!-- TMPL_IF NAME="pubdate_dsc" -->
<option value="pubdate_dsc" selected="selected" >Publication/Copyright Date: Newest to Oldest</option>
	<!-- TMPL_ELSE -->
<option value="pubdate_dsc">Publication/Copyright Date: Newest to Oldest</option>
<!-- /TMPL_IF -->

<!-- TMPL_IF NAME="pubdate_asc" -->
<option value="pubdate_asc" selected="selected" >Publication/Copyright Date: Oldest to Newest</option>
<!-- TMPL_ELSE -->
<option value="pubdate_asc">Publication/Copyright Date: Oldest to Newest</option>
<!-- /TMPL_IF -->

<!-- TMPL_IF NAME="acqdate_dsc" -->
<option value="acqdate_dsc" selected="selected">Acquisition Date: Newest to Oldest</option>
<!-- TMPL_ELSE -->
<option value="acqdate_dsc">Acquisition Date: Newest to Oldest</option>
 <!-- /TMPL_IF -->

 <!-- TMPL_IF NAME="acqdate_asc" -->
<option value="acqdate_asc" selected="selected">Acquisition Date: Oldest to Newest</option>
<!-- TMPL_ELSE -->
<option value="acqdate_asc">Acquisition Date: Oldest to Newest</option>
 <!-- /TMPL_IF -->
</optgroup>

<optgroup label="Title">
	<!-- TMPL_IF NAME="title_az" -->
<option value="title_az" selected="selected">Title (A-Z)</option>
	<!-- TMPL_ELSE -->
<option value="title_az">Title (A-Z)</option>
	 <!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="title_za" -->
<option value="title_za" selected="selected">Title (Z-A)</option>	
	<!-- TMPL_ELSE -->
<option value="title_za">Title (Z-A)</option>
<!-- /TMPL_IF -->
</optgroup>
