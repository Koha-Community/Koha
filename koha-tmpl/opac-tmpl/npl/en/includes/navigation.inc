<div id="nav"><ul><!-- Display for NPL //<li><a href="http://www.athenscounty.lib.oh.us/index.html">home</a></li>

  <li><a href="http://www.athenscounty.lib.oh.us/library.html">your library</a></li>
  <li><a href="http://www.athenscounty.lib.oh.us/readers/index.html">reader's connection</a></li>
    <li><a href="http://www.athenscounty.lib.oh.us/kids/index.html">kids' page</a></li>
    <li><a href="http://www.athenscounty.lib.oh.us/teens/index.html">teens</a></li> /Display for NPL -->
  <li><a href="/cgi-bin/koha/opac-main.pl">library catalog</a>
  	<ul>
		<li><a href="/cgi-bin/koha/opac-main.pl">Catalog Home</a></li>
		<li><a href="/cgi-bin/koha/opac-search.pl">Advanced Search</a></li>
		<!-- Display for NPL //
		<li><a href="/opac-format-search.php">Search by Format and Date</a></li>
		<li><a href="http://66.213.78.70/upcoming.cfm">Upcoming Releases Waiting List</a></li> //Display for NPL -->
	</ul>
	<!-- TMPL_IF NAME="loggedinusername" -->
	</li><li><a href="/cgi-bin/koha/opac-user.pl">my account</a><ul>
		<li><a href="/cgi-bin/koha/opac-shelves.pl">My Book Lists</a></li>
		<li><a href="/cgi-bin/koha/opac-user.pl">My Account</a></li>
		<!-- TMPL_IF name="suggestion" --><li><a href="/cgi-bin/koha/opac-suggestions.pl">Purchase Suggestions</a></li><!-- /TMPL_IF -->
	</ul></li>
	<!-- /TMPL_IF -->
  </li>
 <!-- Display for NPL // <li><a href="http://www.athenscounty.lib.oh.us/programs.asp">programs</a></li>

  <li><a href="http://www.athenscounty.lib.oh.us/branch.html">branches</a></li>
  <li><a href="http://www.athenscounty.lib.oh.us/bookmobile.html">the bookmobile</a></li>
  <li><a href="http://www.oplin.org">OPLIN</a></li>
  <li><a href="http://www.athenscounty.lib.oh.us/contact.html">contact the library</a></li> //Display for NPL -->
  </ul>
</div>