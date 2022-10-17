[% USE Koha %]
[% IF refiner %]
    <select class="advsearch" name="idx" id="refiner_idx">
[% ELSE %]
    <select class="advsearch" name="idx" id="idx">
[% END %]
[% IF ms_kw %]
        <option selected="selected" value="kw">Keyword</option>
    [% ELSE %]
        <option value="kw">Keyword</option>
    [% END %]
[% IF ms_kwcommaphr %]
        <option selected="selected" value="kw,phr">&nbsp;&nbsp;&nbsp;&nbsp; Keyword as phrase</option>
    [% ELSE %]
        <option value="kw,phr">&nbsp;&nbsp;&nbsp;&nbsp; Keyword as phrase</option>
    [% END %]
[% IF ms_au %]
        <option selected="selected" value="au">Author</option>
    [% ELSE %]
        <option value="au">Author</option>
    [% END %]
[% IF ms_aucommaphr %]
        <option selected="selected" value="au,phr">&nbsp;&nbsp;&nbsp;&nbsp; Author as phrase</option>
    [% ELSE %]
        <option value="au,phr">&nbsp;&nbsp;&nbsp;&nbsp; Author as phrase</option>
    [% END %]
[% IF ms_cpn %]
        <option selected="selected" value="cpn">&nbsp;&nbsp;&nbsp;&nbsp; Corporate name</option>
    [% ELSE %]
        <option value="cpn">&nbsp;&nbsp;&nbsp;&nbsp; Corporate name</option>
    [% END %]
[% IF ms_cfn %]
        <option selected="selected" value="cfn">&nbsp;&nbsp;&nbsp;&nbsp; Conference name</option>
    [% ELSE %]
        <option value="cfn">&nbsp;&nbsp;&nbsp;&nbsp; Conference name</option>
    [% END %]
[% IF ms_cpncommaphr %]
        <option selected="selected" value="cpn,phr">&nbsp;&nbsp;&nbsp;&nbsp; Corporate name as phrase</option>
    [% ELSE %]
        <option value="cpn,phr">&nbsp;&nbsp;&nbsp;&nbsp; Corporate name as phrase</option>
    [% END %]
[% IF ms_cfncommaphr %]
        <option selected="selected" value="cfn,phr">&nbsp;&nbsp;&nbsp;&nbsp; Conference name as phrase</option>
    [% ELSE %]
        <option value="cfn,phr">&nbsp;&nbsp;&nbsp;&nbsp; Conference name as phrase</option>
    [% END %]
[% IF ms_pn %]
        <option selected="selected" value="pn">&nbsp;&nbsp;&nbsp;&nbsp; Personal name</option>
    [% ELSE %]
        <option value="pn">&nbsp;&nbsp;&nbsp;&nbsp; Personal name</option>
    [% END %]
[% IF ms_pncommaphr %]
        <option selected="selected" value="pn,phr">&nbsp;&nbsp;&nbsp;&nbsp; Personal name as phrase</option>
    [% ELSE %]
        <option value="pn,phr">&nbsp;&nbsp;&nbsp;&nbsp; Personal name as phrase</option>
    [% END %]
[% IF ms_ti %]
        <option selected="selected" value="ti">Title</option>
    [% ELSE %]
        <option value="ti">Title</option>
    [% END %]
[% IF ms_ticommaphr %]
        <option selected="selected" value="ti,phr">&nbsp;&nbsp;&nbsp;&nbsp; Title as phrase</option>
    [% ELSE %]
        <option value="ti,phr">&nbsp;&nbsp;&nbsp;&nbsp; Title as phrase</option>
    [% END %]
[% IF ms_se %]
        <option selected="seleced" value="se">&nbsp;&nbsp;&nbsp;&nbsp; Series title</option>
    [% ELSE %]
        <option value="se">&nbsp;&nbsp;&nbsp;&nbsp; Series title</option>
    [% END %]
[% IF ms_su %]
        <option selected="selected" value="su">Subject</option>
    [% ELSE %]
        <option value="su">Subject</option>
    [% END %]
[% IF ms_sucommaphr %]
        <option selected="selected" value="su,phr">&nbsp;&nbsp;&nbsp;&nbsp; Subject as phrase</option>
    [% ELSE %]
        <option value="su,phr">&nbsp;&nbsp;&nbsp;&nbsp; Subject as phrase</option>
    [% END %]
[% IF ( expanded_options ) %]
[% IF ms_sudashbr %]
            <option selected="selected" value="su-br">&nbsp;&nbsp;&nbsp;&nbsp; Subject and broader terms</option>
        [% ELSE %]
            <option value="su-br">&nbsp;&nbsp;&nbsp;&nbsp; Subject and broader terms</option>
        [% END %]
[% IF ms_sudashna %]
            <option selected="selected" value="su-na">&nbsp;&nbsp;&nbsp;&nbsp; Subject and narrower terms</option>
        [% ELSE %]
            <option value="su-na">&nbsp;&nbsp;&nbsp;&nbsp; Subject and narrower terms</option>
        [% END %]
[% IF ms_sudashrl %]
            <option selected="selected" value="su-rl">&nbsp;&nbsp;&nbsp;&nbsp; Subject and related terms</option>
        [% ELSE %]
            <option value="su-rl">&nbsp;&nbsp;&nbsp;&nbsp; Subject and related terms</option>
        [% END %]
    [% END %]
[% IF ms_bc %]
        <option selected="selected" value="bc">Barcode</option>
    [% ELSE %]
        <option value="bc">Barcode</option>
    [% END %]
[% IF ms_locationcommawrdl %]
        <option selected="selected" value="location,wrdl" title="Enter location code value for search">Shelving location (code)</option>
    [% ELSE %]
        <option value="location,wrdl" title="Enter location code value for search">Shelving location (code)</option>
    [% END %]
[% IF ( Koha.Preference('IntranetNumbersPreferPhrase') ) %]
[% IF ms_identcommaphr %]
            <option selected="selected" value="ident,phr">Standard number</option>
        [% ELSE %]
            <option value="ident,phr">Standard number</option>
        [% END %]
    [% ELSE %]
[% IF ms_ident %]
            <option selected="selected" value="ident">Standard number</option>
        [% ELSE %]
            <option value="ident">Standard number</option>
        [% END %]
    [% END %]
[% IF ms_nb %]
        <option selected="selected" value="nb">&nbsp;&nbsp;&nbsp;&nbsp; ISBN</option>
    [% ELSE %]
        <option value="nb">&nbsp;&nbsp;&nbsp;&nbsp; ISBN</option>
    [% END %]
[% IF ms_ns %]
        <option selected="selected" value="ns">&nbsp;&nbsp;&nbsp;&nbsp; ISSN</option>
    [% ELSE %]
        <option value="ns">&nbsp;&nbsp;&nbsp;&nbsp; ISSN</option>
    [% END %]
[% IF ( Koha.Preference('IntranetNumbersPreferPhrase') ) %]
[% IF ms_callnumcommaphr %]
            <option selected="selected" value="callnum,phr">&nbsp;&nbsp;&nbsp;&nbsp; Call number</option>
        [% ELSE %]
            <option value="callnum,phr">&nbsp;&nbsp;&nbsp;&nbsp; Call number</option>
        [% END %]
    [% ELSE %]
[% IF ms_callnum %]
            <option selected="selected" value="callnum">&nbsp;&nbsp;&nbsp;&nbsp; Call number</option>
        [% ELSE %]
            <option value="callnum">&nbsp;&nbsp;&nbsp;&nbsp; Call number</option>
        [% END %]
    [% END %]
[% IF ms_lncommartrn %]
        <option selected="selected" value="ln,rtrn">Language</option>
    [% ELSE %]
        <option value="ln,rtrn">Language</option>
    [% END %]
[% IF ms_nt %]
        <option selected="selected" value="nt">Notes/Comments</option>
    [% ELSE %]
        <option value="nt">Notes/Comments</option>
    [% END %]
[% IF (marcflavour != 'UNIMARC' ) %]
[% IF ms_curriculum %]
            <option selected="selected" value="curriculum">Curriculum</option>
        [% ELSE %]
            <option value="curriculum">Curriculum</option>
        [% END %]
    [% END %]
[% IF ms_pb %]
        <option selected="selected" value="pb">Publisher</option>
    [% ELSE %]
        <option value="pb">Publisher</option>
    [% END %]
[% IF ms_pl %]
        <option selected="selected" value="pl">Publisher location</option>
    [% ELSE %]
        <option value="pl">Publisher location</option>
    [% END %]

    [%# Use non-normalized st-year instead of st-numeric, %]
    [%# since pubdate can include 'u' to signify unknown %]
    [%# dates. See "Legal Characters" at: %]
    [%# http://www.loc.gov/marc/bibliographic/bd008a.html %]
    [%# This search is also for date ranges due to the %]
    [%# special Zebra r=r CCL mapping for 'yr' %]
[% IF ms_yrcommastdashyear %]
        <option selected="selected" value="yr,st-year">Publication date (yyyy-yyyy)</option>
    [% ELSE %]
        <option value="yr,st-year">Publication date (yyyy-yyyy)</option>
    [% END %]
[% IF ms_acqdatecommastdashdatedashnormalized %]
        <option selected="selected" value="acqdate,st-date-normalized">Acquisition date (yyyy-mm-dd)</option>
    [% ELSE %]
        <option value="acqdate,st-date-normalized">Acquisition date (yyyy-mm-dd)</option>
    [% END %]
</select>
