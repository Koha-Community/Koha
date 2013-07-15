<div id="search-facets">
<h4>Refine your search</h4>
<form method="get" action="/cgi-bin/koha/opac-topissues.pl">
		<fieldset>
          <ol>  <li><label for="limit">Show the top </label> <select name="limit" id="limit" style="width: 10em;">
                            [% IF ( limit == 10 ) %]<option value ="10" selected="selected">10 titles</option>[% ELSE %]<option value="10">10 titles</option>[% END %]
                            [% IF ( limit == 15 ) %]<option value ="15" selected="selected">15 titles</option>[% ELSE %]<option value="15">15 titles</option>[% END %]
                            [% IF ( limit == 20 ) %]<option value ="20" selected="selected">20 titles</option>[% ELSE %]<option value="20">20 titles</option>[% END %]
                            [% IF ( limit == 30 ) %]<option value ="30" selected="selected">30 titles</option>[% ELSE %]<option value="30">30 titles</option>[% END %]
                            [% IF ( limit == 40 ) %]<option value ="40" selected="selected">40 titles</option>[% ELSE %]<option value="40">40 titles</option>[% END %]
                            [% IF ( limit == 50 ) %]<option value ="50" selected="selected">50 titles</option>[% ELSE %]<option value="50">50 titles</option>[% END %]
                            [% IF ( limit == 100 ) %]<option value ="100" selected="selected">100 titles</option>[% ELSE %]<option value="100">100 titles</option>[% END %]
                        </select>
						</li>
				<li>
               <label for="branch">From: </label>
                <select name="branch" id="branch" style="width: 10em;">
                <option value="">All libraries</option>
                [% FOREACH branchloo IN branchloop %]
                    [% IF ( branchloo.selected ) %]<option value="[% branchloo.value %]" selected="selected">[% ELSE %]<option value="[% branchloo.value %]">[% END %]
                        [% branchloo.branchname %]
                    </option>
                [% END %]
                </select>
            </li>
            <li><label for="itemtype">Limit to: </label>
                    <select name="itemtype" id="itemtype" style="width: 10em;">
                        [% IF ( ccodesearch ) %]<option value="">All collections</option>[% ELSE %]<option value="">All item types</option>[% END %]
                        [% FOREACH itemtypeloo IN itemtypeloop %]
                            [% IF ( itemtypeloo.selected ) %]<option value="[% itemtypeloo.value %]" selected="selected">[% ELSE %]<option value="[% itemtypeloo.value %]">[% END %]
                                [% itemtypeloo.description %]
                            </option>
                        [% END %]
                    </select></li>
			<li>
            <label for="timeLimit">Acquired in the last:</label> <select name="timeLimit" id="timeLimit">
                [% IF ( timeLimit == 3 ) %]<option value="3" selected="selected">3 months</option>[% ELSE %]<option value="3">3 months</option>[% END %]
                 [% IF ( timeLimit == 6 ) %]<option value="6" selected="selected">6 months</option>[% ELSE %]<option value="6">6 months</option>[% END %]
                 [% IF ( timeLimit == 12 ) %]<option value="12" selected="selected">12 months</option>[% ELSE %]<option value="12">12 months</option>[% END %]
                 [% IF ( timeLimit == 999 ) %]<option value="999" selected="selected">No limit</option>[% ELSE %]<option value="999">No limit</option>[% END %]
				</select>
            </li></ol>
        <input type="hidden" name="do_it" value="1" />
		
    </fieldset><fieldset class="action"><input type="submit" value="Submit" /></fieldset>
    </form>
</div>
