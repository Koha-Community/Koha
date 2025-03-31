[% USE Koha %]
<div id="toolbar" class="btn-toolbar">
    <div class="btn-group"
        ><a href="#" id="clear" class="btn btn-default btn-sm"><i class="fa fa-trash-can"></i> Clear field</a></div
    >
    <div class="btn-group"
        ><a href="#" id="createnew" class="btn btn-default btn-sm"><i class="fa fa-plus"></i> Create new authority</a></div
    >
</div>
<form name="f" method="get" action="auth_finder.pl" class="clearfix">
    <input type="hidden" name="source" value="[% source | html %]" />
    <input type="hidden" name="op" value="do_search" />
    <input type="hidden" name="type" value="intranet" />
    <input type="hidden" name="index" value="[% index | html %]" />
    <fieldset class="rows">
        <legend class="collapsed"><i class="fa fa-caret-down" title="Collapse this section"></i> Search options</legend>
        <ol style="display:none">
            <li>
                <span class="label">Authority type: </span>
                [% authtypecode | html %]
                <input type="hidden" name="authtypecode" value="[% authtypecode | html %]" />
            </li>
            <li>
                <label for="mainmainentry">Search main heading ($a only): </label>
                <input type="hidden" name="marclist" value="mainmainentry" />
                <input type="hidden" name="and_or" value="and" />
                <input type="hidden" name="excluding" value="" />
                <select name="operator" id="mainmainentry">
                    [% IF ( operator_mainstr == 'contains' ) %]
                        <option value="contains" selected="selected">contains</option>
                    [% ELSE %]
                        <option value="contains">contains</option>
                    [% END %]
                    [% IF ( operator_mainstr == 'start' ) %]
                        <option value="start" selected="selected">starts with</option>
                    [% ELSE %]
                        <option value="start">starts with</option>
                    [% END %]
                    [% IF ( operator_mainstr == 'exact' ) %]
                        <option value="exact" selected="selected">is exactly</option>
                    [% ELSE %]
                        <option value="exact">is exactly</option>
                    [% END %]
                </select>
                <input id="value_mainstr" style="width:400px;" type="text" name="value_mainstr" value="[% value_mainstr | html %]" />
                <div id="yvaluecontainermainmainentry"></div>
            </li>

            <li>
                <label for="mainentry">Search main heading: </label>
                <input type="hidden" name="marclist" value="mainentry" />
                <input type="hidden" name="and_or" value="and" />
                <input type="hidden" name="excluding" value="" />
                <select name="operator" id="mainentry">
                    [% IF ( operator_main == 'contains' ) %]
                        <option value="contains" selected="selected">contains</option>
                    [% ELSE %]
                        <option value="contains">contains</option>
                    [% END %]
                    [% IF ( operator_main == 'start' ) %]
                        <option value="start" selected="selected">starts with</option>
                    [% ELSE %]
                        <option value="start">starts with</option>
                    [% END %]
                    [% IF ( operator_main == 'exact' ) %]
                        <option value="exact" selected="selected">is exactly</option>
                    [% ELSE %]
                        <option value="exact">is exactly</option>
                    [% END %]
                </select>
                <input id="value_main" style="width:400px;" type="text" name="value_main" value="[% value_main | html %]" />
                <div id="yvaluecontainermainentry"></div>
            </li>
            <li>
                <label for="marclistheading">Search all headings: </label>
                <input type="hidden" name="marclist" value="match" />
                <input type="hidden" name="and_or" value="and" />
                <input type="hidden" name="excluding" value="" />
                <select name="operator" id="marclistheading">
                    [% IF ( operator_match == 'contains' ) %]
                        <option value="contains" selected="selected">contains</option>
                    [% ELSE %]
                        <option value="contains">contains</option>
                    [% END %]
                    [% IF ( operator_match == 'start' ) %]
                        <option value="start" selected="selected">starts with</option>
                    [% ELSE %]
                        <option value="start">starts with</option>
                    [% END %]
                    [% IF ( operator_match == 'exact' ) %]
                        <option value="exact" selected="selected">is exactly</option>
                    [% ELSE %]
                        <option value="exact">is exactly</option>
                    [% END %]
                </select>
                <input id="value_match" style="width:400px;" type="text" name="value_match" value="[% value_match | html %]" />
                <div id="yvaluecontainermarclistheading"></div>
            </li>
            <li>
                <label for="marclistanywhere">Search entire record: </label>
                <input type="hidden" name="marclist" value="all" />
                <input type="hidden" name="and_or" value="and" />
                <input type="hidden" name="excluding" value="" />
                <select name="operator" id="marclistanywhere">
                    [% IF ( operator_any == 'contains' ) %]
                        <option value="contains" selected="selected">contains</option>
                    [% ELSE %]
                        <option value="contains">contains</option>
                    [% END %]
                    [% IF ( operator_any == 'start' ) %]
                        <option value="start" selected="selected">starts with</option>
                    [% ELSE %]
                        <option value="start">starts with</option>
                    [% END %]
                    [% IF ( operator_any == 'exact' ) %]
                        <option value="exact" selected="selected">is exactly</option>
                    [% ELSE %]
                        <option value="exact">is exactly</option>
                    [% END %]
                </select>
                <input id="value_any" style="width:400px;" type="text" name="value_any" value="[% value_any | html %]" />
                <div id="yvaluecontainermarclist"></div>
            </li>
            <li>
                <label for="orderby">Sort by: </label>
                <select name="orderby" id="orderby">
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
            </li></ol
        ></fieldset
    >
    [% IF source == 'auth' %]
        <fieldset class="rows"
            ><legend>Relationship information</legend>
            <ol>
                <li>
                    <label for="special_relationship">Special relationship: </label>
                    <select name="relationship" id="special_relationship">
                        [% selected=relationship | html %]
                        <option>None specified</option>
                        [% IF Koha.Preference('marcflavour') == 'MARC21' %]
                            <option [% IF selected == 'a' %]selected="selected"[% END %] value="a">a - Earlier heading</option>
                            <option [% IF selected == 'b' %]selected="selected"[% END %] value="b">b - Later heading</option>
                            <option [% IF selected == 'd' %]selected="selected"[% END %] value="d">d - Acronym</option>
                            <option [% IF selected == 'f' %]selected="selected"[% END %] value="f">f - Musical composition</option>
                            <option [% IF selected == 'g' %]selected="selected"[% END %] value="g">g - Broader term</option>
                            <option [% IF selected == 'h' %]selected="selected"[% END %] value="h">h - Narrower term</option>
                            <option [% IF selected == 'i' %]selected="selected"[% END %] value="i">i - Reference instruction phrase in subfield $i</option>
                            <option [% IF selected == 'n' %]selected="selected"[% END %] value="n">n - Not applicable</option>
                            <option [% IF selected == 'r' %]selected="selected"[% END %] value="r">r - Relationship designation in $i or $4</option>
                            <option [% IF selected == 't' %]selected="selected"[% END %] value="t">t - Immediate parent body</option>
                        [% ELSIF Koha.Preference('marcflavour') == 'UNIMARC' %]
                            <option [% IF selected == 'a' %]selected="selected"[% END %] value="a">a = earlier name</option>
                            <option [% IF selected == 'b' %]selected="selected"[% END %] value="b">b = later name</option>
                            <option [% IF selected == 'c' %]selected="selected"[% END %] value="c">c = official name</option>
                            <option [% IF selected == 'd' %]selected="selected"[% END %] value="d">d = acronym / initial / abbreviation</option>
                            <option [% IF selected == 'e' %]selected="selected"[% END %] value="e">e = pseudonym</option>
                            <option [% IF selected == 'f' %]selected="selected"[% END %] value="f">f = real name</option>
                            <option [% IF selected == 'g' %]selected="selected"[% END %] value="g">g = broader term or name</option>
                            <option [% IF selected == 'h' %]selected="selected"[% END %] value="h">h = narrower term or name</option>
                            <option [% IF selected == 'i' %]selected="selected"[% END %] value="i">i = name in religion</option>
                            <option [% IF selected == 'j' %]selected="selected"[% END %] value="j">j = married name</option>
                            <option [% IF selected == 'k' %]selected="selected"[% END %] value="k">k = name before marriage</option>
                            <option [% IF selected == 'l' %]selected="selected"[% END %] value="l">l = shared pseudonym</option>
                            <option [% IF selected == 'm' %]selected="selected"[% END %] value="m">m = secular name</option>
                            <option [% IF selected == 'n' %]selected="selected"[% END %] value="n">n = different rule form of a name</option>
                            <option [% IF selected == 'o' %]selected="selected"[% END %] value="o">o = attributed name / conventional title of a work</option>
                            <option [% IF selected == 'x' %]selected="selected"[% END %] value="x">x = not applicable</option>
                            <option [% IF selected == 'z' %]selected="selected"[% END %] value="z">z = other</option>
                        [% END %]
                    </select>
                </li>
            </ol>
        </fieldset>
    [% END %]

    <nav class="navbar navbar-default fixed-bottom">
        <div class="container-fluid">
            <fieldset class="action">
                <input type="submit" class="btn btn-primary" id="search" value="Search" />
                <input type="reset" id="clear-form" class="btn btn-default" value="Clear form" />
                <button type="button" class="btn btn-default close_window">Close window</button>
            </fieldset>
        </div>
    </nav>
</form>
