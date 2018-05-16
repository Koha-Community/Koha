[% USE Koha %]
<select class="advsearch" name="idx">
    <option value="kw">Keyword</option>
    <option value="kw,phr">&nbsp;&nbsp;&nbsp;&nbsp; Keyword as phrase</option>
    <option value="au">Author</option>
    <option value="au,phr">&nbsp;&nbsp;&nbsp;&nbsp; Author as phrase</option>
    <option value="cpn">&nbsp;&nbsp;&nbsp;&nbsp; Corporate name</option>
    <option value="cfn">&nbsp;&nbsp;&nbsp;&nbsp; Conference name</option>
    <option value="cpn,phr">&nbsp;&nbsp;&nbsp;&nbsp; Corporate name as phrase</option>
    <option value="cfn,phr">&nbsp;&nbsp;&nbsp;&nbsp; Conference name as phrase</option>
    <option value="pn">&nbsp;&nbsp;&nbsp;&nbsp; Personal name</option>
    <option value="pn,phr">&nbsp;&nbsp;&nbsp;&nbsp; Personal name as phrase</option>
    <option value="ti">Title</option>
    <option value="ti,phr">&nbsp;&nbsp;&nbsp;&nbsp; Title as phrase</option>
    <option value="se">&nbsp;&nbsp;&nbsp;&nbsp; Series title</option>
    <option value="su">Subject</option>
    <option value="su,phr">&nbsp;&nbsp;&nbsp;&nbsp; Subject as phrase</option>
    [% IF ( expanded_options ) %]
        <option value="su-br">&nbsp;&nbsp;&nbsp;&nbsp; Subject and broader terms</option>
        <option value="su-na">&nbsp;&nbsp;&nbsp;&nbsp; Subject and narrower terms</option>
        <option value="su-rl">&nbsp;&nbsp;&nbsp;&nbsp; Subject and related terms</option>
    [% END %]
    <option value="bc">Barcode</option>
    <option value="location">Shelving location</option>
    [% IF ( Koha.Preference('IntranetNumbersPreferPhrase') ) %]
    <option value="ident,phr">Standard number</option>
    [% ELSE %]
    <option value="ident">Standard number</option>
    [% END %]
    <option value="nb">&nbsp;&nbsp;&nbsp;&nbsp; ISBN</option>
    <option value="ns">&nbsp;&nbsp;&nbsp;&nbsp; ISSN</option>
    [% IF ( Koha.Preference('IntranetNumbersPreferPhrase') ) %]
    <option value="callnum,phr">&nbsp;&nbsp;&nbsp;&nbsp; Call number</option>
    [% ELSE %]
    <option value="callnum">&nbsp;&nbsp;&nbsp;&nbsp; Call number</option>
    [% END %]
    <option value="ln,rtrn">Language</option>
    <option value="nt">Notes/Comments</option>
    [% IF (marcflavour != 'UNIMARC' ) %]
        <option value="curriculum">Curriculum</option>
    [% END %]
    <option value="pb">Publisher</option>
    <option value="pl">Publisher location</option>

    [%# Use non-normalized st-year instead of st-numeric, %]
    [%# since pubdate can include 'u' to signify unknown %]
    [%# dates. See "Legal Characters" at: %]
    [%# http://www.loc.gov/marc/bibliographic/bd008a.html %]
    [%# This search is also for date ranges due to the %]
    [%# special Zebra r=r CCL mapping for 'yr' %]
    <option value="yr,st-year">Publication date (yyyy-yyyy)</option>
    <option value="acqdate,st-date-normalized">Acquisition date (yyyy-mm-dd)</option>
</select>
