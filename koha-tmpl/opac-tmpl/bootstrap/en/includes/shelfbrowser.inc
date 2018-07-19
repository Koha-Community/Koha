[% BLOCK shelfbrowser %]
    [% IF OpenOPACShelfBrowser %]
        <div id="shelfbrowser">
            <h5 style="text-align: center;">
                [% IF ( starting_homebranch ) %]Browsing [% starting_homebranch %] Shelves[% END %]
                [% IF ( starting_location ) %], Shelving location: [% starting_location %][% END %]
                [% IF ( starting_ccode ) %], Collection code: [% starting_ccode %][% END %]
                <a style="font-size: 75%;" href="/cgi-bin/koha/opac-detail.pl?biblionumber=[% biblionumber %]" class="close_shelf" >Close shelf browser</a>
            </h5>

            <table class="table">
                <tr>
                    <td rowspan="2">
                      [% IF shelfbrowser_prev_item %]
                        <div id="browser_previous">
                            <a href="/cgi-bin/koha/opac-detail.pl?biblionumber=[% shelfbrowser_prev_item.biblionumber %]&amp;shelfbrowse_itemnumber=[% shelfbrowser_prev_item.itemnumber %]#shelfbrowser" data-prev-itemnumber="[% shelfbrowser_prev_item.itemnumber %]">Previous</a>
                        </div>
                      [% END %]
                    </td>

                    [% FOREACH item IN shelfbrowser_items %]
                        <td>
                            <a href="/cgi-bin/koha/opac-detail.pl?biblionumber=[% item.biblionumber %]&amp;shelfbrowse_itemnumber=[% item.itemnumber %]#shelfbrowser">
                                [% IF ( OPACLocalCoverImages ) %]
                                    <div title="[% item.biblionumber |url %]" class="[% item.biblionumber %] thumbnail-shelfbrowser" id="local-thumbnail-shelf-[% item.biblionumber %]"></div>
                                [% END %]
                                [% IF ( OPACAmazonCoverImages ) %]
                                    [% IF ( item.browser_normalized_isbn ) %]
                                        <img src="https://images-na.ssl-images-amazon.com/images/P/[% item.browser_normalized_isbn %].01._AA75_PU_PU-5_.jpg" alt="" />
                                    [% ELSE %]
                                        <span class="no-image">No cover image available</span>
                                    [% END %]
                                [% END %]

                                [% IF ( SyndeticsEnabled ) %]
                                    [% IF ( SyndeticsCoverImages ) %]
                                        [% IF ( content_identifier_exists ) %]
                                            <img src="https://secure.syndetics.com/index.aspx?isbn=[% item.browser_normalized_isbn %]/SC.GIF&amp;client=[% SyndeticsClientCode %][% IF ( item.browser_normalized_upc ) %]&amp;upc=[% item.browser_normalized_upc %][% END %][% IF ( item.browser_normalized_oclc ) %]&amp;oclc=[% item.browser_normalized_oclc %][% END %]&amp;type=xw10" alt="" />
                                        [% ELSE %]
                                            <span class="no-image">No cover image available</span>
                                        [% END %]
                                    [% END %]
                                [% END %]

                                [% IF ( GoogleJackets ) %]
                                    [% IF ( item.browser_normalized_isbn ) %]
                                        <div title="[% item.biblionumber |url %]" class="[% item.browser_normalized_isbn %]" id="gbs-thumbnail-preview[% loop.count %]"></div>
                                    [% ELSE %]
                                        <span class="no-image">No cover image available</span>
                                    [% END %]
                                [% END %]
                                [% IF ( Koha.Preference('Coce') && Koha.Preference('CoceProviders') ) %]
                                  [% coce_id = item.browser_normalized_ean || item.browser_normalized_isbn %]
                                  <div title="[% item.biblionumber |url %]" class="[% coce_id %]" id="coce-thumbnail-preview-[% coce_id %]"></div>
                                [% END %]
                                [% IF ( BakerTaylorEnabled ) %]
                                    [% bt_id = ( item.browser_normalized_upc || item.browser_normalized_isbn ) %]
                                    [% IF ( bt_id ) %]
                                        <img alt="See Baker &amp; Taylor" src="[% BakerTaylorImageURL |html %][% bt_id %]" />
                                    [% ELSE %]
                                        <span class="no-image">No cover image available</span>
                                    [% END %]
                                [% END %]
                            </a>
                        </td>
                    [% END %]
                    <td rowspan="2">
                        [% IF shelfbrowser_next_item %]
                            <div id="browser_next">
                                <a href="/cgi-bin/koha/opac-detail.pl?biblionumber=[% shelfbrowser_next_item.biblionumber %]&amp;shelfbrowse_itemnumber=[% shelfbrowser_next_item.itemnumber %]#shelfbrowser" data-next-itemnumber="[% shelfbrowser_next_item.itemnumber %]">Next</a>
                            </div>
                        [% END %]
                    </td>
                </tr>

                <tr>
                    [% FOREACH item IN shelfbrowser_items %]
                        <td class="top">
                            [% item.itemcallnumber %]
                            <a href="/cgi-bin/koha/opac-detail.pl?biblionumber=[% item.biblionumber %]&amp;shelfbrowse_itemnumber=[% item.itemnumber %]#shelfbrowser">
                                [% item.title |html %]
                                [% FOREACH subtitl IN item.subtitle %]
                                    [% IF Koha.Preference('marcflavour')=='UNIMARC' %],[% END %]
                                    [% subtitl.subfield |html %]
                                [% END %]
                            </a>
                        </td>
                    [% END %]
                </tr>
            </table>
        </div>
    [% END # /IF OpenOPACShelfBrowser %]
[% END # end of shelfbrowser block %]
