[% PROCESS 'html_helpers.inc' %]
<div id="advsearch" style="padding-bottom:3em;">
    <form action="/cgi-bin/koha/serials/serials-search.pl" method="get">
        [% IF brief %]
            <fieldset class="brief">
        [% ELSE %]
            <fieldset class="rows">
        [% END%]
            <legend>Search subscriptions</legend>
            <ol>
                <li>
                    <label for="issn">ISSN:</label>
                    <input type="text" id="issn" name="ISSN_filter" value="[% ISSN_filter | html %]" />
                </li>
                <li>
                    <label for="title">Title:</label>
                    <input type="text" id="title" name="title_filter" value="[% title_filter | html %]" />
                </li>
                [% IF ( marcflavour == "UNIMARC" ) %]
                    <li>
                        <label for="ean">EAN:</label>
                        <input type="text" id="ean" name="EAN_filter" value="[% EAN_filter | html %]" />
                    </li>
                [% END %]
                <li class="local">
                    <label for="callnumber">Call number:</label>
                    <input type="text" id="callnumber" name="callnumber_filter" value="[% callnumber_filter | html %]" />
                </li>
                <li>
                    <label for="publisher">Publisher:</label>
                    <input type="text" id="publisher" name="publisher_filter" value="[% publisher_filter | html %]" />
                </li>
                <li class="local">
                    <label for="bookseller">Vendor:</label>
                    <input type="text" id="bookseller" name="bookseller_filter" value="[% bookseller_filter | html %]" />
                </li>
                <li class="local">
                    <label for="branch">Library:</label>
                    <select id="branch" name="branch_filter">
                        <option value="">All</option>
                        [%# FIXME Should not we filter the libraries? %]
                        [% PROCESS options_for_libraries libraries => Branches.all( selected => branch_filter, unfiltered => 1 ) %]
                    </select>
                </li>
                <li class="local">
                    <label for="location">Location:</label>
                    [% PROCESS 'av-build-dropbox.inc' name="location_filter", category="LOC", default=location_filter, all=1 %]
                </li>
                <li class="local">
                    <label for="to">Expires before:</label>
                    <input type="text" id="to" name="expiration_date_filter" value="[% expiration_date_filter | html %]" size="10" maxlength="10" class="flatpickr" />
                </li>
                [% INCLUDE 'additional-fields-entry.inc' available=additional_fields_for_subscription values=additional_field_filters wrap_fieldset=0 %]
            </ol>
            <input type="hidden" name="searched" value="1" />
            [% IF ( mana ) %]
                <input type="hidden" name="mana" value="1" />
            [% END %]
            <fieldset class="action">
                <input type="submit" class="btn btn-primary" value="Search" />
            </fieldset>
        </fieldset> <!-- /.rows -->
    </form>
</div> <!-- /#advsearch -->
