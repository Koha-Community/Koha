<!-- authorities-search.inc -->

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
    <div>
        <label>
            Authority type
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
        </label>
    </div>
[% END %]

<div id="header_search" role="tablist">
    <div class="tab-content">
        <div id="mainmain_heading" role="tabpanel" class="tab-pane active">
            <form action="/cgi-bin/koha/authorities/authorities-home.pl" method="get">
                <input type="hidden" name="op" value="do_search" />
                <input type="hidden" name="type" value="intranet" />
                <input type="hidden" name="marclist" value="mainmainentry" />
                <input type="hidden" name="and_or" value="and" />
                <input type="hidden" name="excluding" value="" />

                <div class="form-title">
                    <label class="control-label" for="value_mainentry"><span class="control-text">Search main heading</span> <i class="fa fa-fw fa-main-heading-a" aria-hidden="true"></i></label>
                </div>

                <div class="form-content">
                    <input id="value_mainentry" class="form-control head-searchbox" type="text" name="value" value="[% value | html %]" placeholder="Search main heading ($a only)" />
                    <button type="button" class="form-extra-content-toggle" title="More options"><i class="form-extra-content-icon fa-solid fa-sliders" aria-hidden="true"></i></button>
                </div>

                <button type="submit" aria-label="Search"><i class="fa fa-arrow-right"></i></button>

                <div class="form-extra-content">
                    [% INCLUDE authtype %]
                    [% INCLUDE operator %]
                    [% INCLUDE orderby %]
                </div>
            </form>
        </div>

        <div id="main_heading" role="tabpanel" class="tab-pane">
            <form action="/cgi-bin/koha/authorities/authorities-home.pl" method="get">
                <input type="hidden" name="marclist" value="mainentry" />
                <input type="hidden" name="and_or" value="and" />
                <input type="hidden" name="excluding" value="" />
                <input type="hidden" name="op" value="do_search" />
                <input type="hidden" name="type" value="intranet" />

                <div class="form-title">
                    <label class="control-label" for="value_mainheading"><span class="control-text">Search main heading</span> <i class="fa fa-fw fa-header" aria-hidden="true"></i></label>
                </div>

                <div class="form-content">
                    <input id="value_mainheading" class="form-control head-searchbox" type="text" name="value" value="[% value | html %]" placeholder="Search main heading" />
                    <button type="button" class="form-extra-content-toggle" title="More options"><i class="form-extra-content-icon fa-solid fa-sliders" aria-hidden="true"></i></button>
                </div>

                <button type="submit" aria-label="Search"><i class="fa fa-arrow-right"></i></button>

                <div class="form-extra-content">
                    [% INCLUDE authtype %]
                    [% INCLUDE operator %]
                    [% INCLUDE orderby %]
                </div>
            </form>
        </div>

        <div id="matchheading_search" role="tabpanel" class="tab-pane">
            <form action="/cgi-bin/koha/authorities/authorities-home.pl" method="get">
                <input type="hidden" name="op" value="do_search" />
                <input type="hidden" name="type" value="intranet" />
                <input type="hidden" name="marclist" value="match" />

                <div class="form-title">
                    <label class="control-label" for="value_matchheading"><span class="control-text">Search all headings</span> <i class="fa fa-fw fa-align-center" aria-hidden="true"></i></label>
                </div>

                <div class="form-content">
                    <input id="value_matchheading" class="form-control head-searchbox" type="text" name="value" value="[% value | html %]" placeholder="Search any heading" />
                    <button type="button" class="form-extra-content-toggle" title="More options"><i class="form-extra-content-icon fa-solid fa-sliders" aria-hidden="true"></i></button>
                </div>

                <button type="submit" aria-label="Search"><i class="fa fa-arrow-right"></i></button>

                <div class="form-extra-content">
                    [% INCLUDE authtype %]
                    [% INCLUDE operator %]
                    [% INCLUDE orderby %]
                </div>
            </form>
        </div>

        <div id="entire_record" role="tabpanel" class="tab-pane">
            <form action="/cgi-bin/koha/authorities/authorities-home.pl" method="get">
                <input type="hidden" name="op" value="do_search" />
                <input type="hidden" name="type" value="intranet" />
                <input type="hidden" name="marclist" value="all" />
                <input type="hidden" name="and_or" value="and" />
                <input type="hidden" name="excluding" value="" />

                <div class="form-title">
                    <label class="control-label" for="value_anywhere"><span class="control-text">Search entire record</span> <i class="fa-solid fa-fw fa-folder-open" aria-hidden="true"></i></label>
                </div>

                <div class="form-content">
                    <input id="value_anywhere" class="form-control head-searchbox" type="text" name="value" value="[% value | html %]" placeholder="Search any authority field" />
                    <button type="button" class="form-extra-content-toggle" title="More options"><i class="form-extra-content-icon fa-solid fa-sliders" aria-hidden="true"></i></button>
                </div>

                <button type="submit" aria-label="Search"><i class="fa fa-arrow-right"></i></button>

                <div class="form-extra-content">
                    [% INCLUDE authtype %]
                    [% INCLUDE operator %]
                    [% INCLUDE orderby %]
                </div>
            </form>
        </div>

    </div><!-- /.tab-content -->
    <ul class="nav nav-tabs" role="tablist">
        <li role="presentation" class="active">
            <a title="Search main heading ($a only)" href="#mainmain_heading" aria-controls="mainmain_heading" role="tab"  aria-expanded="true" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-main-heading-a" aria-hidden="true"></i> <span class="tab-title">Main heading ($a only)</span></a>
        </li>
        <li role="presentation">
            <a title="Search main heading" href="#main_heading" aria-controls="main_heading" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-header" aria-hidden="true"></i> <span class="tab-title">Main heading</span></a>
        </li>
        <li role="presentation">
            <a title="Search all headings" href="#matchheading_search" aria-controls="matchheading_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-align-center" aria-hidden="true"></i> <span class="tab-title">All headings</span></a>
        </li>
        <li role="presentation">
            <a title="Search entire record" href="#entire_record" aria-controls="entire_record" role="tab" data-toggle="tab" class="keep_text"><i class="fa-solid fa-fw fa-folder-open" aria-hidden="true"></i> <span class="tab-title">Entire record</span></a>
        </li>
        <li role="presentation">
    </ul>
</div><!-- /#header_search -->
<!-- /authorities-search.inc -->
