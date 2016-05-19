<div id="advsearch">
    <form action="" method="get">
        <fieldset class="brief">
        <a href="#" class="toggle_element" data-element="#advsearch_form">Advanced search</a>
            <div id="advsearch_form" style="display:none">
            <ol>
              <li>
                <label for="issn">ISSN:</label>
                <input type="text" id="issn" name="ISSN_filter" value="[% ISSN_filter %]" />
              </li>
              <li>
                <label for="title">Title:</label>
                <input type="text" id="title" name="title_filter" value="[% title_filter %]" />
              </li>
              [% IF Koha.Preference( 'marcflavour' ) == "UNIMARC" %]
              <li>
                <label for="ean">EAN:</label>
                <input type="text" id="ean" name="EAN_filter" value="[% EAN_filter %]" />
              </li>
              [% END %]
              <li>
                <label for="publisher">Publisher:</label>
                <input type="text" id="publisher" name="publisher_filter" value="[% publisher_filter %]" />
              </li>
              <li>
                <label for="supplier">Vendor:</label>
                <input type="text" id="supplier" name="supplier_filter" value="[% supplier_filter %]" />
              </li>
              <li>
                <label for="branch">Library:</label>
                <select id="branch" name="branch_filter">
                  <option value="">All</option>
                  [% FOREACH branch IN branches_loop %]
                    [% IF (branch.selected) %]
                      <option selected="branch.selected" value="[% branch.branchcode %]">[% branch.branchname %]</option>
                    [% ELSE %]
                      <option value="[% branch.branchcode %]">[% branch.branchname %]</option>
                    [% END %]
                  [% END %]
                </select>
              </li>
            </ol>
            <input type="hidden" name="searched" value="1" />
            [% IF (booksellerid) %]
                <input type="hidden" name="booksellerid" value="[% booksellerid %]" />
            [% END %]
            [% IF (basketno) %]
                <input type="hidden" name="basketno" value="[% basketno %]" />
            [% END %]
            <fieldset class="action">
              <input type="submit" value="Search" />
            </fieldset>
            </div>
        </fieldset>
    </form>
</div>
