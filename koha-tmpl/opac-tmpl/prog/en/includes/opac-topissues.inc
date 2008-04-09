<div id="search-facets">
<h4>Refine your search</h4>
<form method="get" action="/cgi-bin/koha/opac-topissues.pl">
		<fieldset>
          <ol>  <li><label for="limit">Show the top </label> <select name="limit" id="limit" style="width: 10em;">
                            <!-- TMPL_IF EXPR="limit == 10" --><option value ="10" selected="selected">10 titles</option><!-- TMPL_ELSE --><option value="10">10 titles</option><!-- /TMPL_IF -->
                            <!-- TMPL_IF EXPR="limit == 15" --><option value ="15" selected="selected">15 titles</option><!-- TMPL_ELSE --><option value="15">15 titles</option><!-- /TMPL_IF -->
                            <!-- TMPL_IF EXPR="limit == 20" --><option value ="20" selected="selected">20 titles</option><!-- TMPL_ELSE --><option value="20">20 titles</option><!-- /TMPL_IF -->
                            <!-- TMPL_IF EXPR="limit == 30" --><option value ="30" selected="selected">30 titles</option><!-- TMPL_ELSE --><option value="30">30 titles</option><!-- /TMPL_IF -->
                            <!-- TMPL_IF EXPR="limit == 40" --><option value ="40" selected="selected">40 titles</option><!-- TMPL_ELSE --><option value="40">40 titles</option><!-- /TMPL_IF -->
                            <!-- TMPL_IF EXPR="limit == 50" --><option value ="50" selected="selected">50 titles</option><!-- TMPL_ELSE --><option value="50">50 titles</option><!-- /TMPL_IF -->
                            <!-- TMPL_IF EXPR="limit == 100" --><option value ="100" selected="selected">100 titles</option><!-- TMPL_ELSE --><option value="100">100 titles</option><!-- /TMPL_IF -->
                        </select>
						</li>
				<li>
               <label for="branch">From: </label>
                <select name="branch" id="branch" style="width: 10em;">
                <option value="">All branches</option>
                <!-- TMPL_LOOP name="branchloop" -->
                    <!-- TMPL_IF EXPR="branch eq branchname" --><option value="<!-- TMPL_VAR name="value" -->" selected="selected"><!-- TMPL_ELSE --><option value="<!-- TMPL_VAR name="value" -->"><!-- /TMPL_IF -->
                        <!-- TMPL_VAR name="branchname" -->
                    </option>
                <!-- /TMPL_LOOP -->
                </select>
            </li>
            <li><label for="itemtype">Limit to: </label>
                    <select name="itemtype" id="itemtype" style="width: 10em;">
                        <option value="">All item types</option>
                        <!-- TMPL_LOOP name="itemtypeloop" -->
                            <!-- TMPL_IF EXPR="itemtype eq description" --><option value="<!-- TMPL_VAR name="value" -->" selected="selected"><!-- TMPL_ELSE --><option value="<!-- TMPL_VAR name="value" -->"><!-- /TMPL_IF -->
                                <!-- TMPL_VAR name="description" -->
                            </option>
                        <!-- /TMPL_LOOP -->
                    </select></li>
			<li>
            <label for="timeLimit">Acquired in the last:</label> <select name="timeLimit" id="timeLimit">
                <!-- TMPL_IF EXPR="timeLimit == 3" --><option value="3" selected="selected">3 months</option><!-- TMPL_ELSE --><option value="3">3 months</option><!-- /TMPL_IF -->
                 <!-- TMPL_IF EXPR="timeLimit == 6" --><option value="6" selected="selected">6 months</option><!-- TMPL_ELSE --><option value="6">6 months</option><!-- /TMPL_IF -->
                 <!-- TMPL_IF EXPR="timeLimit == 12" --><option value="12" selected="selected">12 months</option><!-- TMPL_ELSE --><option value="12">12 months</option><!-- /TMPL_IF -->
                 <!-- TMPL_IF EXPR="timeLimit == 999" --><option value="999" selected="selected">No limit</option><!-- TMPL_ELSE --><option value="999">No limit</option><!-- /TMPL_IF -->
				</select>
            </li></ol>
        <input type="hidden" name="do_it" value="1" />
		
    </fieldset><fieldset class="action"><input type="submit" value="Submit" /></fieldset>
    </form>
</div>