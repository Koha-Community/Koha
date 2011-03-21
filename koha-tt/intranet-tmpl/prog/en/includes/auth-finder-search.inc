<form name="f" method="get" action="auth_finder.pl">
            <input type="hidden" name="op" value="do_search" />
            <input type="hidden" name="type" value="intranet" />
            <input type="hidden" name="index" value="[% index %]" />
                <fieldset class="rows"><ol><li>
                    <span class="label">Authority type</span>
                    [% authtypecode %]
                    <input type="hidden" name="authtypecode" value="[% authtypecode %]" />
                </li>
                <li>
                    <label for="mainmainentry">Main entry ($a only)</label>
                    <input type="hidden" name="marclist" value="mainmainentry" />
                    <input type="hidden" name="and_or" value="and" />
                    <input type="hidden" name="excluding" value="" />
                    <select name="operator" id="mainmainentry">
                        <option value="contains">contains</option>
                        <option value="start">starts with</option>
                        <option value="is">is exactly</option>
                    </select>
                    <input type="text" name="value_mainstr" value="[% value_mainstr |html %]" />
                </li>
                <li>
                    <label for="mainentry">Main entry</label>
                    <input type="hidden" name="marclist" value="mainentry" />
                    <input type="hidden" name="and_or" value="and" />
                    <input type="hidden" name="excluding" value="" />
                    <select name="operator" id="mainentry">
                        <option value="contains">contains</option>
                        <option value="start">starts with</option>
                        <option value="is">is exactly</option>
                    </select>
                    <input type="text" name="value_main" value="[% value_main |html %]" />
                </li>
                <li>
                    <label for="marclist">Anywhere</label>
                    <input type="hidden" name="marclist" value="" />
                    <input type="hidden" name="and_or" value="and" />
                    <input type="hidden" name="excluding" value="" />
                    <select name="operator" id="marclist">
                        <option value="contains">contains</option>
                        <option value="start">starts with</option>
                        <option value="is">is exactly</option>
                    </select>
                    <input type="text" name="value_any" value="[% value_any |html %]" />
                </li>
		<li>
		<label for="orderby">Sort by </label>
		<select name="orderby" id="orderby">
		    <option value="">No order</option>
            <option value="HeadingAsc" selected="selected">Heading Ascendant</option>
            <option value="HeadingDsc">Heading Descendant</option>
        </select>
		</li></ol></fieldset>
            <fieldset class="action"> <input type="submit" value="Start search" class="submit" /> <a class="cancel close" href="#">Cancel</a></fieldset>
</form>
