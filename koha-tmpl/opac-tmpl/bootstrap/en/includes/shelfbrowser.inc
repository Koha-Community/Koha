[% BLOCK shelfbrowser %]
    [% IF OpenOPACShelfBrowser %]
        <div id="shelfbrowser">
            <h5 style="text-align: center;" tabindex="-1">
                [%- IF ( starting_homebranch ) %]<span>Browsing [% starting_homebranch | html %] shelves</span>[% END -%]
                [%- IF ( starting_homebranch && starting_location ) %], [% END %]
                [%- IF ( starting_location ) %]<span>Shelving location:</span> [%- starting_location | html -%][% END -%]
                [%- IF ( starting_homebranch && starting_ccode ) %], [% END %]
                    [%- IF ( starting_ccode ) %]<span>Collection: [%- starting_ccode | html -%]</span>[% END -%]
                <a style="font-size: 75%;" href="/cgi-bin/koha/opac-detail.pl?biblionumber=[% biblionumber | html %]" class="close_shelf" >Close shelf browser <span class="sr-only">(Hides shelf browser)</span></a>
            </h5>

            <table class="table">
                <tr>
                    <td class="nav-cell" rowspan="2">
                      [% IF shelfbrowser_prev_item %]
                        <div id="browser_previous">
                            <a href="/cgi-bin/koha/opac-detail.pl?biblionumber=[% shelfbrowser_prev_item.biblionumber | uri %]&amp;shelfbrowse_itemnumber=[% shelfbrowser_prev_item.itemnumber | uri %]#shelfbrowser" data-prev-itemnumber="[% shelfbrowser_prev_item.itemnumber | html %]"><i class="fa fa-caret-up" aria-hidden="true"></i> Previous</a>
                        </div>
                      [% END %]
                    </td>

                    [% FOREACH item IN shelfbrowser_items %]
                        <td>
                            [% IF ( item.title ) %]
                                [% img_title = item.title %]
                            [% ELSE %]
                                [% img_title = item.biblionumber %]
                            [% END %]

                            [% IF ( OPACLocalCoverImages || OPACAmazonCoverImages || ( SyndeticsEnabled && SyndeticsCoverImages ) || GoogleJackets || BakerTaylorEnabled || ( Koha.Preference('OpacCoce') && Koha.Preference('CoceProviders') ) || ( Koha.Preference('OPACCustomCoverImages') AND Koha.Preference('CustomCoverImagesURL') ) ) %]
                                <a class="shelfbrowser_cover" href="/cgi-bin/koha/opac-detail.pl?biblionumber=[% item.biblionumber | uri %]&amp;shelfbrowse_itemnumber=[% item.itemnumber | uri %]#shelfbrowser">
                                    [% IF ( OPACLocalCoverImages ) %]
                                        <div title="[% img_title | html %]" class="[% item.biblionumber | html %] thumbnail-shelfbrowser" id="local-thumbnail-shelf-[% item.biblionumber | html %]"></div>
                                    [% END %]
                                    [% IF ( OPACAmazonCoverImages ) %]
                                        [% IF ( item.browser_normalized_isbn ) %]
                                            <img src="https://images-na.ssl-images-amazon.com/images/P/[% item.browser_normalized_isbn | html %].01._AA75_PU_PU-5_.jpg" alt="" />
                                        [% ELSE %]
                                            <span class="no-image">No cover image available</span>
                                        [% END %]
                                    [% END %]

                                    [% IF ( SyndeticsEnabled ) %]
                                        [% IF ( SyndeticsCoverImages ) %]
                                            [% IF ( item.browser_normalized_isbn ) %]
                                                <img src="https://secure.syndetics.com/index.aspx?isbn=[% item.browser_normalized_isbn | html %]/[% SyndeticsCoverImageSize | uri %].GIF&amp;client=[% SyndeticsClientCode | html %][% IF ( item.browser_normalized_upc ) %]&amp;upc=[% item.browser_normalized_upc | html %][% END %][% IF ( item.browser_normalized_oclc ) %]&amp;oclc=[% item.browser_normalized_oclc | html %][% END %]&amp;type=xw10" alt="" />
                                            [% ELSE %]
                                                <span class="no-image">No cover image available</span>
                                            [% END %]
                                        [% END %]
                                    [% END %]

                                    [% IF ( GoogleJackets ) %]
                                        [% IF ( item.browser_normalized_isbn ) %]
                                            <div title="[% img_title | html %]" class="[% item.browser_normalized_isbn | html %]" id="gbs-thumbnail-preview[% loop.count | html %]"></div>
                                        [% ELSE %]
                                            <span class="no-image">No cover image available</span>
                                        [% END %]
                                    [% END %]
                                    [% IF ( Koha.Preference('OpacCoce') && Koha.Preference('CoceProviders') ) %]
                                    [% coce_id = item.browser_normalized_ean || item.browser_normalized_isbn | html %]
                                    <div title="[% img_title | html %]" class="[% coce_id | html %]" id="coce-thumbnail-preview-[% coce_id | html %]"></div>
                                    [% END %]
                                    [% IF ( BakerTaylorEnabled ) %]
                                        [% bt_id = ( item.browser_normalized_upc || item.browser_normalized_isbn ) | html %]
                                        [% IF ( bt_id ) %]
                                            <img alt="See Baker &amp; Taylor" src="[% BakerTaylorImageURL | html %][% bt_id | html %]" />
                                        [% ELSE %]
                                            <span class="no-image">No cover image available</span>
                                        [% END %]
                                    [% END %]
                                    [% IF Koha.Preference('OPACCustomCoverImages') AND Koha.Preference('CustomCoverImagesURL') %]
                                        [% SET custom_cover_image_url = item.biblio_object.custom_cover_image_url %]
                                        [% IF custom_cover_image_url %]
                                            <span class="custom_cover_image">
                                                <img alt="Cover image" src="[% custom_cover_image_url | url %]" />
                                            </span>
                                        [% END %]
                                    [% END %]

                                </a>
                            [% END %]
                        </td>
                    [% END %]
                    <td class="nav-cell" rowspan="2">
                        [% IF shelfbrowser_next_item %]
                            <div id="browser_next">
                                <a href="/cgi-bin/koha/opac-detail.pl?biblionumber=[% shelfbrowser_next_item.biblionumber | uri %]&amp;shelfbrowse_itemnumber=[% shelfbrowser_next_item.itemnumber | uri %]#shelfbrowser" data-next-itemnumber="[% shelfbrowser_next_item.itemnumber | html %]">Next <i class="fa fa-caret-up" aria-hidden="true"></i></a>
                            </div>
                        [% END %]
                    </td>
                </tr>

                <tr>
                    [% FOREACH item IN shelfbrowser_items %]
                        <td class="top">
                            [% item.itemcallnumber | html %]
                            <a href="/cgi-bin/koha/opac-detail.pl?biblionumber=[% item.biblionumber | uri %]&amp;shelfbrowse_itemnumber=[% item.itemnumber | uri %]#shelfbrowser">
                                [% INCLUDE 'biblio-title.inc' biblio=item %]
                            </a>
                        </td>
                    [% END %]
                </tr>
            </table>
        </div>
    [% END # /IF OpenOPACShelfBrowser %]
[% END # end of shelfbrowser block %]
