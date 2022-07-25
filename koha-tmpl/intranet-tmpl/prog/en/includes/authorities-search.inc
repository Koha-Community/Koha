<!-- Begin Authorities Resident Search Box -->

[% BLOCK orderby %]
    <div>
        <label class="control-label">
            Order by

            <select name="orderby" class="form-control">
                [% IF ( orderby == 'HeadingAsc' ) %]
                <option value="HeadingAsc" selected="selected">Heading A-Z</option>
                [% ELSE %]
                <option value="HeadingAsc">Heading A-Z</option>
                [% END %]
                [% IF ( orderby == 'HeadingDsc' ) %]
                <option value="HeadingDsc" selected="selected">Heading Z-A</option>
                [% ELSE %]
                <option value="HeadingDsc">Heading Z-A</option>
                [% END %]
                [% IF ( orderby == '' && op ) %]
                <option value="" selected="selected">None</option>
                [% ELSE %]
                <option value="">None</option>
                [% END %]
            </select>
        </label>
    </div>
[% END %]

[% BLOCK operator %]
    <div>
        <label class="control-label">
            Operator

            <select name="operator" class="form-control">
                [% IF ( operator == 'contains' ) %]
                <option value="contains" selected="selected">contains</option>
                [% ELSE %]
                <option value="contains">contains</option>
                [% END %]
                [% IF ( operator == 'start' ) %]
                <option value="start" selected="selected">starts with</option>
                [% ELSE %]
                <option value="start">starts with</option>
                [% END %]
                [% IF ( operator == 'exact' ) %]
                <option value="exact" selected="selected">is exactly</option>
                [% ELSE %]
                <option value="exact">is exactly</option>
                [% END %]
            </select>
        </label>
    </div>
[% END %]

[% BLOCK authtype %]
    <select name="authtypecode" class="form-control">
    [% IF (marcflavour == 'UNIMARC' ) %]<option value="">All authority types</option>[% END %]
    [% FOREACH authority_type IN authority_types %]
        [% IF authority_type.authtypecode == authtypecode %]
        <option value="[% authority_type.authtypecode | html %]" selected="selected">[% authority_type.authtypetext | html %]</option>
        [% ELSE %]
        <option value="[% authority_type.authtypecode | html %]">[% authority_type.authtypetext | html %]</option>
        [% END %]
    [% END %]
    </select>
[% END %]

<div id="header_search" class="navbar-form navbar-left">
    <div id="mainmain_heading" class="residentsearch">
        <form action="/cgi-bin/koha/authorities/authorities-home.pl" method="get">
            <input type="hidden" name="op" value="do_search" />
            <input type="hidden" name="type" value="intranet" />
            <input type="hidden" name="marclist" value="mainmainentry" />
            <input type="hidden" name="and_or" value="and" />
            <input type="hidden" name="excluding" value="" />

            <span class="form-title">
                <label class="control-label">Main heading ($a)</label>
            </span>

            <span class="form-content">
                [% INCLUDE authtype %]
                <input id="value_mainentry" class="form-control" type="text" name="value" value="[% value | html %]" placeholder="Search main heading ($a only)" />
                <button type="button" class="form-extra-content-toggle"><i class="fa fa-sliders"></i></button>
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>

            <span class="form-extra-content">
                [% INCLUDE operator %]
                [% INCLUDE orderby %]
            </span>
        </form>
    </div>

    <div id="main_heading" class="residentsearch">
        <form action="/cgi-bin/koha/authorities/authorities-home.pl" method="get">
            <input type="hidden" name="marclist" value="mainentry" />
            <input type="hidden" name="and_or" value="and" />
            <input type="hidden" name="excluding" value="" />
            <input type="hidden" name="op" value="do_search" />
            <input type="hidden" name="type" value="intranet" />

            <span class="form-title">
                <label class="control-label">Main heading</label>
            </span>

            <span class="form-content">
                [% INCLUDE authtype %]
                <input id="value_mainheading" class="form-control" type="text" name="value" value="[% value | html %]" placeholder="Search main heading" />
                <button type="button" class="form-extra-content-toggle"><i class="fa fa-sliders"></i></button>
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>

            <span class="form-extra-content">
                [% INCLUDE operator %]
                [% INCLUDE orderby %]
            </span>
        </form>
    </div>

    <div id="matchheading_search" class="residentsearch">
        <form action="/cgi-bin/koha/authorities/authorities-home.pl" method="get">
            <input type="hidden" name="op" value="do_search" />
            <input type="hidden" name="type" value="intranet" />
            <input type="hidden" name="marclist" value="match" />

            <span class="form-title">
                <label class="control-label">All headings</label>
            </span>

            <span class="form-content">
                [% INCLUDE authtype %]
                <input id="value_matchheading" class="form-control" type="text" name="value" value="[% value | html %]" placeholder="Search any heading" />
                <button type="button" class="form-extra-content-toggle"><i class="fa fa-sliders"></i></button>
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>

            <span class="form-extra-content">
                [% INCLUDE operator %]
                [% INCLUDE orderby %]
            </span>
        </form>
    </div>

    <div id="entire_record" class="residentsearch">
        <form action="/cgi-bin/koha/authorities/authorities-home.pl" method="get">
            <input type="hidden" name="op" value="do_search" />
            <input type="hidden" name="type" value="intranet" />
            <input type="hidden" name="marclist" value="all" />
            <input type="hidden" name="and_or" value="and" />
            <input type="hidden" name="excluding" value="" />

            <span class="form-title">
                <label class="control-label">Entire record</label>
            </span>

            <span class="form-content">
                [% INCLUDE authtype %]
                <input id="value_anywhere" class="form-control" type="text" name="value" value="[% value | html %]" placeholder="Search any authority field" />
                <button type="button" class="form-extra-content-toggle"><i class="fa fa-sliders"></i></button>
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>

            <span class="form-extra-content">
                [% INCLUDE operator %]
                [% INCLUDE orderby %]
            </span>
        </form>
    </div>

    <ul>
        <li><a title="Search main heading ($a only)" href="#mainmain_heading"><i style="font-weight:bold">$a</i></a></li>
        <li><a title="Search main heading" href="#main_heading"><i class="fa fa-header"></i></a></li>
        <li><a title="Search all headings" href="#matchheading_search"><i class="fa fa-align-center"></i></a></li>
        <li><a title="Search entire record" href="#entire_record"><i class="fa fa-folder-open-o"></i></a></li>
    </ul>
</div><!-- /header_search -->
<!-- End Authorities Resident Search Box -->
