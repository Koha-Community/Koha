<form name="f" method="post" action="auth_finder.pl">
            <input type="hidden" name="op" value="do_search" />
            <input type="hidden" name="type" value="intranet" />
            <input type="hidden" name="nbstatements" value="<!-- TMPL_VAR NAME="nbstatements" -->" />
            <input type="hidden" name="index" value="<!-- TMPL_VAR NAME="index" -->" />
            <h2>Search on</h2>
                <p>
                    <label>Authority type</label>
                    <!-- TMPL_VAR NAME="authtypecode" -->
                    <input type="hidden" name="authtypecode" value="<!-- TMPL_VAR NAME="authtypecode" -->" />
                </p>
                <p>
                    <label>Main entry ($a only)</label>
                    <input type="hidden" name="marclist" value="mainmainentry" />
                    <input type="hidden" name="and_or" value="and" />
                    <input type="hidden" name="excluding" value="" />
                    <select name="operator">
                        <option value="contains">contains</option>
                        <option value="start">starts with</option>
                        <option value="is">is exactly</option>
                    </select>
                    <input type="text" name="value" value="<!-- TMPL_VAR name="mainmainstring" -->" />
                </p>
                <p>
                    <label>Main entry</label>
                    <input type="hidden" name="marclist" value="mainentry" />
                    <input type="hidden" name="and_or" value="and" />
                    <input type="hidden" name="excluding" value="" />
                    <select name="operator">
                        <option value="contains">contains</option>
                        <option value="start">starts with</option>
                        <option value="is">is exactly</option>
                    </select>
                    <input type="text" name="value" value="<!-- TMPL_VAR name="mainstring" -->" />
                </p>
                <p>
                    <label>Anywhere</label>
                    <input type="hidden" name="marclist" value="" />
                    <input type="hidden" name="and_or" value="and" />
                    <input type="hidden" name="excluding" value="" />
                    <select name="operator" >
                        <option value="contains">contains</option>
                        <option value="start">starts with</option>
                        <option value="is">is exactly</option>
                    </select>
                    </select>
                    <input type="text" name="value" value="<!-- TMPL_VAR name="anystring" -->" />
                </p>
		<p>
		 Sort by 
		<select name="orderby">
		<option value="">No order</option>
            	<option value="HeadingAsc" selected="SELECTED">Heading Ascendant</option>
            	<option value="HeadingDsc">Heading Descendant</option>
          	</select>
                <p>
                <input type="submit" value="Start search" class="button" />
                </p>
        </form>
