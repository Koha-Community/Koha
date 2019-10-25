[% USE raw %]
[% USE Biblio %]
<ul id="action">
    [% UNLESS ( norequests ) %]
        [% IF Koha.Preference( 'opacuserlogin' ) == 1 %]
            [% IF Koha.Preference( 'RequestOnOpac' ) == 1 %]
                [% IF ( ReservableItems ) %]
                    <li><a class="reserve btn btn-link btn-lg" href="/cgi-bin/koha/opac-reserve.pl?biblionumber=[% biblio.biblionumber | html %]"><i class="fa fa-fw fa-bookmark"></i> Place hold</a></li>
                [% END %]
            [% END %]
        [% END %]
    [% END %]

    <li><a class="print-large btn btn-link btn-lg" href="#"><i class="fa fa-fw fa-print"></i> Print</a></li>

    [% IF Koha.Preference( 'opacuserlogin' ) == 1 %]
        [% IF artreqpossible %]
            <li><a class="article_request btn btn-link btn-lg" href="/cgi-bin/koha/opac-request-article.pl?biblionumber=[% biblio.biblionumber | html %]"><i class="fa fa-fw fa-file-text"></i> Request article</a></li>
        [% END %]
    [% END %]

    [% IF Koha.Preference( 'virtualshelves' ) == 1 %]
        [% IF ( ( Koha.Preference( 'opacuserlogin' ) == 1 ) && loggedinusername ) %]
            <li><a class="addtoshelf btn btn-link btn-lg" href="/cgi-bin/koha/opac-addbybiblionumber.pl?biblionumber=[% biblio.biblionumber | html %]"><i class="fa fa-fw fa-list"></i> Save to your lists</a></li>
        [% END %]
    [% END %]

    [% IF Koha.Preference( 'opacbookbag' ) == 1 %]
        [% IF ( incart ) %]
            <li><a data-biblionumber="[% biblio.biblionumber | html %]" class="addtocart incart cart[% biblio.biblionumber | html %] addrecord btn btn-link btn-lg" href="#"><i class="fa fa-fw fa-shopping-cart"></i> In your cart</a> <a data-biblionumber="[% biblio.biblionumber | html %]" class="cartRemove cartR[% biblio.biblionumber | html %]" href="#">(remove)</a></li>
        [% ELSE %]
            <li><a data-biblionumber="[% biblio.biblionumber | html %]" class="addtocart cart[% biblio.biblionumber | html %] addrecord btn btn-link btn-lg" href="#"><i class="fa fa-fw fa-shopping-cart"></i> Add to your cart</a>  <a style="display:none;" data-biblionumber="[% biblio.biblionumber | html %]" class="cartRemove cartR[% biblio.biblionumber | html %]" href="#">(remove)</a></li>
        [% END %]
    [% END %]

    [% IF ( OpacHighlightedWords && query_desc ) %]
    <li>
        <a href="#" class="highlight_toggle btn btn-link btn-lg" id="highlight_toggle_off"><i class="fa fa-fw fa-pencil"></i> Unhighlight</a>
        <a href="#" class="highlight_toggle btn btn-link btn-lg" id="highlight_toggle_on"><i class="fa fa-fw fa-pencil"></i> Highlight</a>
    </li>
    [% END %]


    [% IF ( Koha.Preference('OPACDetailQRCode' ) ) %]
        <li>
            <a class="show_qrcode btn btn-link btn-lg" href="#"><i class="fa fa-fw fa-qrcode"></i> Send to device</a>
            <div id="qrcode" class="hidden"></div>
        </li>
    [% END %]

    [% SET export_options = Koha.Preference('OpacExportOptions').split(',') %]
    [% IF export_options.size %]
        <li>
            <div id="export">
                <div class="dropdown">
                    <a id="format" class="btn btn-link btn-lg dropdown-toggle" data-toggle="dropdown" href="#"><i class="fa fa-fw fa-download"></i> Save record <b class="caret"></b></a>
                        <ul class="dropdown-menu pull-left" role="menu" aria-labelledby="format">
                            [% FOREACH option IN export_options %]
                                [% IF option == 'dc' %]
                                    <li><a role="menuitem" href="#" data-toggle="modal" data-target="#exportModal_">Dublin Core</a></li>
                                [% ELSE %]
                                <li>
                                    <a role="menuitem" href="/cgi-bin/koha/opac-export.pl?op=export&amp;bib=[% biblio.biblionumber | html %]&amp;format=[% option | html %]">
                                        [% SWITCH option %]
                                            [% CASE 'bibtex' %]BIBTEX
                                            [% CASE 'endnote' %]EndNote
                                            [% CASE 'marcxml' %]MARCXML
                                            [% CASE 'marc8' %]MARC (non-Unicode/MARC-8)
                                            [% CASE 'utf8' %]MARC (Unicode/UTF-8)
                                            [% CASE 'marcstd' %]MARC (Unicode/UTF-8, Standard)
                                            [% CASE 'mods' %]MODS (XML)
                                            [% CASE 'ris' %]RIS
                                            [% CASE 'isbd' %]ISBD
                                        [% END %]
                                    </a>
                                </li>
                                [% END %]
                            [% END %]
                        </ul>
                </div>
            </div>
        </li>
    [% END %]

    [% IF ( OPACSearchForTitleIn ) %]
        <li>
            <div id="moresearches_menu">
                <div class="dropdown">
                    <a id="furthersearches" class="btn btn-link btn-lg dropdown-toggle" data-toggle="dropdown" href="#"><i class="fa fa-fw fa-search"></i> More searches <b class="caret"></b></a>
                        <ul class="dropdown-menu pull-left" role="menu" aria-labelledby="furthersearches">
                            <li><a href="#" class="menu-inactive">Search for this title in:</a></li>
                            [% OPACSearchForTitleIn | $raw %]
                        </ul>
                </div>
            </div>
        </li>
    [% END %]
</ul>

<!-- Dublin Core Modal Form -->
<div class="modal hide" id="exportModal_" tabindex="-1" role="dialog" aria-labelledby="exportModalLabel" aria-hidden="true">
    <div class="modal-header">
        <button type="button" class="closebtn" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h3 class="modal-title" id="exportModalLabel">Exporting to Dublin Core...</h3>
    </div>
    <form method="get" action="/cgi-bin/koha/opac-export.pl">
    <div class="modal-body">
        <fieldset id="dc_fieldset">
                <input id="input-simple" type="radio" name="format" value="rdfdc">
                <label class="label_dc" for="input-simple">Simple DC-RDF</label>
                <br>
                <input id="input-oai" type="radio" name="format" value="oaidc" checked>
                <label class="label_dc" for="input-oai">OAI-DC</label>
                <br>
                <input id="input-srw" type="radio" name="format" value="srwdc">
                <label class="label_dc" for="input-srw">SRW-DC</label>
                <br>
        <input type="hidden" name="op" value="export">
        <input type="hidden" name="bib" value="[% biblio.biblionumber | html %]">
        </fieldset>
    </div>
    <div class="modal-footer">
        <button type="submit" class="btn">Export</button>
        <button class="btn btn-link btn-lg" data-dismiss="modal" aria-hidden="true">Cancel</button>
    </div>
    </form>
</div>
