<ul id="action">
    [% UNLESS ( norequests ) %]
        [% IF ( opacuserlogin ) %]
            [% IF ( RequestOnOpac ) %]
                [% IF ( AllowOnShelfHolds ) %]
                    <li><a class="reserve" href="/cgi-bin/koha/opac-reserve.pl?biblionumber=[% biblionumber %]">Place hold</a></li>
                [% ELSE %]
                    [% IF ( ItemsIssued ) %]
                        <li><a class="reserve" href="/cgi-bin/koha/opac-reserve.pl?biblionumber=[% biblionumber %]">Place hold</a></li>
                    [% END %]
                [% END %]
            [% END %]
        [% END %]
    [% END %]
    <li><a class="print" href="#" onclick="window.print();">Print</a></li>
    [% IF ( virtualshelves ) %]
        [% IF ( opacuserlogin ) %][% IF ( loggedinusername ) %]
            <li><a class="addtoshelf" href="/cgi-bin/koha/opac-addbybiblionumber.pl?biblionumber=[% biblionumber %]" onclick="Dopop('opac-addbybiblionumber.pl?biblionumber=[% biblionumber %]'); return false;">
                Save to your lists
            </a></li>
        [% END %][% END %]
    [% END %]
    [% IF ( opacbookbag ) %]
        [% IF ( incart ) %]
            <li><a class="incart cart[% biblionumber %]" href="#" onclick="addRecord('[% biblionumber %]'); return false;">In your cart</a> <a class="cartRemove cartR[% biblionumber %]" href="#" onclick="delSingleRecord('[% biblionumber %]'); return false;">(remove)</a></li>
        [% ELSE %]
            <li><a class="addtocart cart[% biblionumber %]" href="#" onclick="addRecord('[% biblionumber %]'); return false;">Add to your cart</a>  <a style="display:none;" class="cartRemove cartR[% biblionumber %]" href="#" onclick="delSingleRecord('[% biblionumber %]'); return false;">(remove)</a></li>
        [% END %]
    [% END %]
    [% IF ( OpacHighlightedWords && query_desc ) %]
    <li>
        <a href="#" class="highlight_toggle" id="highlight_toggle_off">Unhighlight</a>
        <a href="#" class="highlight_toggle" id="highlight_toggle_on">Highlight</a>
    </li>
    [% END %]
    <li style="display:none;"><a href="#" id="furthersearches">More searches</a></li>
</ul>

[% IF ( OPACSearchForTitleIn ) %]
    <div id="furtherm" class="yuimenu">
    <div class="bd">
    <h4>Search for this title in:</h4>
    <ul class="first-of-type">
        [% OPACSearchForTitleIn %]
    </ul>
    </div>
    </div>
[% END %]

[% IF ( export_options.size ) %]
    <div id="export" class="detailtagcell">
        <form method="get" action="/cgi-bin/koha/opac-export.pl">
        <label for="format">Save record:</label>
        <select name="format" id="format">
        [% FOREACH option IN export_options %]
            [% SWITCH option %]
                [% CASE 'bibtex' %]<option value="bibtex">BIBTEX</option>
                [% CASE 'dc' %]<option value="dc">Dublin Core (XML)</option>
                [% CASE 'marcxml' %]<option value="marcxml">MARCXML</option>
                [% CASE 'marc8' %]<option value="marc8">MARC (non-Unicode/MARC-8)</option>
                [% CASE 'utf8' %]<option value="utf8">MARC (Unicode/UTF-8)</option>
                [% CASE 'marcstd' %]<option value="marcstd">MARC (Unicode/UTF-8, Standard)</option>
                [% CASE 'mods' %]<option value="mods">MODS (XML)</option>
                [% CASE 'ris' %]<option value="ris">RIS</option>
            [% END %]
        [% END %]
        </select>
        <input type="hidden" name="op" value="export" />
        <input type="hidden" name="bib" value="[% biblionumber %]" />
        <input type="submit" name="save" value="Go" /></form>
    </div>
[% END %]
