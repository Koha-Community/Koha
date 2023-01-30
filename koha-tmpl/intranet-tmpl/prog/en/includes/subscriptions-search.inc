[% PROCESS 'html_helpers.inc' %]
<div id="advsearch">
    <form action="" method="get">
        <fieldset class="brief">
        <a href="#" class="toggle_element" data-element="#advsearch_form">Advanced search</a>
            <div id="advsearch_form" style="display:none">
            <ol>
              <li>
                <label for="issn">ISSN:</label>
                <input type="text" id="issn" name="ISSN_filter" value="[% ISSN_filter | html %]" />
              </li>
              <li>
                <label for="title">Title:</label>
                <input type="text" id="title" name="title_filter" value="[% title_filter | html %]" />
              </li>
              [% IF Koha.Preference( 'marcflavour' ) == "UNIMARC" %]
              <li>
                <label for="ean">EAN:</label>
                <input type="text" id="ean" name="EAN_filter" value="[% EAN_filter | html %]" />
              </li>
              [% END %]
              <li>
                <label for="publisher">Publisher:</label>
                <input type="text" id="publisher" name="publisher_filter" value="[% publisher_filter | html %]" />
              </li>
              <li>
                <label for="supplier">Vendor:</label>
                <input type="text" id="supplier" name="supplier_filter" value="[% supplier_filter | html %]" />
              </li>
              <li>
                <label for="branch">Library:</label>
                <select id="branch" name="branch_filter">
                  <option value="">All</option>
                  [%# FIXME Should not we filter the libraries? %]
                  [% PROCESS options_for_libraries libraries => Branches.all( selected => branch_filter, unfiltered => 1 ) %]
                </select>
              </li>
            </ol>
            <input type="hidden" name="searched" value="1" />
            [% IF (booksellerid) %]
                <input type="hidden" name="booksellerid" value="[% booksellerid | html %]" />
            [% END %]
            [% IF (basketno) %]
                <input type="hidden" name="basketno" value="[% basketno | html %]" />
            [% END %]
            </div>
        </fieldset>
        <fieldset class="action">
            <input type="submit" class="btn btn-primary" value="Search" />
        </fieldset>
    </form>
</div>
