<!-- TMPL_IF NAME="borrowernumber" -->
<div class="patroninfo"><h5><!-- TMPL_VAR name="firstname" --> <!-- TMPL_VAR name="surname" --></h5>
<ul>
	        <li><!-- TMPL_IF NAME="streetaddress"-->
            <!-- TMPL_VAR NAME="streetaddress" -->,
        <!-- TMPL_ELSE -->
            <span class="problem">No address stored for patron.</span>
        <!-- /TMPL_IF --></li>
       <li> <!-- TMPL_IF NAME="city" -->
            <!-- TMPL_VAR NAME="city" -->
        <!-- TMPL_ELSE -->
            No city stored.
        <!-- /TMPL_IF --></li>
   <li> <!--TMPL_IF NAME="phone" -->
        <!-- TMPL_VAR NAME="phone" -->
    <!-- TMPL_ELSE -->
        <span class="problem">No phone stored.</span>    
    <!-- /TMPL_IF --></li>
	    <!-- TMPL_IF NAME="email" -->
   <li> <a href="mailto:<!-- TMPL_VAR NAME="email" -->"><!-- TMPL_VAR NAME="email" --></a></li>
    <!-- /TMPL_IF -->
		    <!-- TMPL_IF NAME="emailpro" -->
   <li> <a href="mailto:<!-- TMPL_VAR NAME="emailpro" -->"><!-- TMPL_VAR NAME="emailpro" --></a></li>
    <!-- /TMPL_IF -->
    <li>Category: <!-- TMPL_VAR name="categorycode" --></li>
</ul></div>
<div class="patronviews">
<ul><li><a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Details</a></li>
	<li><a href="/cgi-bin/koha/members/boraccount.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Fines</a></li>
	<!-- TMPL_IF NAME="intranetreadinghistory" --><li><a href="/cgi-bin/koha/members/readingrec.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Reading Record</a></li><!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="CAN_user_parameters"--><li><a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;module=MEMBERS&amp;action=MODIFY&amp;object=<!-- TMPL_VAR NAME="borrowernumber" -->">Modification Log</a></li><!-- /TMPL_IF --></ul>
<!-- /TMPL_IF -->
</div>

<ul>
	<li><a href="/cgi-bin/koha/circ/returns.pl">Check In</a></li>
	<li><a href="/cgi-bin/koha/circ/branchtransfers.pl">Transfer</a></li>
	<li>    <a href="/cgi-bin/koha/circ/selectbranchprinter.pl">Set library</a></li>
</ul>



<h5>Circulation Reports</h5>
<ul class="left-nav">
	<li>    <a href="/cgi-bin/koha/circ/pendingreserves.pl" title="holds to retrieve off the shelf">Holds to pull</a></li>
	<li>    <a href="/cgi-bin/koha/circ/waitingreserves.pl" title="holds waiting for patron pickup">Holds awaiting pickup</a></li>
	<li>    <a href="/cgi-bin/koha/circ/transferstodo.pl" title="transfers to do from your library">Transfers to do</a></li>

	<li>    <a href="/cgi-bin/koha/circ/transferstoreceive.pl" title="transfers to receive at your library">Transfers to receive</a></li>
	<li>    <a href="/cgi-bin/koha/circ/overdue.pl">Overdues</a></li>
	<li>    <a href="/cgi-bin/koha/circ/branchoverdues.pl">Fines</a></li>
	<li>    <a href="/cgi-bin/koha/circ/stats.pl?time=yesterday">Daily reconciliation</a></li>
</ul>
