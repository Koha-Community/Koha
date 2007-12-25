<!-- TMPL_IF NAME="borrowernumber" -->
<div class="patroninfo"><h5><!-- TMPL_VAR name="firstname" --> <!-- TMPL_VAR name="surname" --> (<!-- TMPL_VAR NAME="cardnumber" -->)</h5>
<ul>
<!-- TMPL_IF NAME="patronimages" --><li><img src="/intranet-tmpl/patronimages/<!-- TMPL_VAR NAME="cardnumber" -->.jpg" alt="" border="0"   style="margin: .3em 0 .3em .3em; padding: .2em; border: 1px solid #CCCCCC;" /></li><!-- /TMPL_IF -->
	        <li><!-- TMPL_IF NAME="address"-->
            <!-- TMPL_VAR NAME="address" -->
        <!-- TMPL_ELSE -->
            <span class="problem">No address stored for patron.</span>
        <!-- /TMPL_IF --></li>
		<!-- TMPL_IF NAME="address2" --><li><!-- TMPL_VAR NAME="address2" --></li><!-- /TMPL_IF -->
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
   <li class="email"> <a href="mailto:<!-- TMPL_VAR NAME="email" -->" title="<!-- TMPL_VAR NAME="email" -->"><!-- TMPL_VAR NAME="email" --></a></li>
    <!-- /TMPL_IF -->
		    <!-- TMPL_IF NAME="emailpro" -->
   <li class="email"> <a href="mailto:<!-- TMPL_VAR NAME="emailpro" -->" title="<!-- TMPL_VAR NAME="emailpro" -->"><!-- TMPL_VAR NAME="emailpro" --></a></li>
    <!-- /TMPL_IF -->
    <li>Category: <!-- TMPL_VAR name="categorycode" --></li>
</ul></div>
<div id="menu">
<ul>
	<!-- TMPL_IF NAME="circview" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Check Out</a></li>
	<!-- TMPL_IF NAME="detailview" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Details</a></li>
	<!-- TMPL_IF NAME="finesview" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a href="/cgi-bin/koha/members/boraccount.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Fines</a></li>
	<!-- TMPL_IF NAME="intranetreadinghistory" --><li><a href="/cgi-bin/koha/members/readingrec.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Circulation History</a></li><!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="CAN_user_parameters"--><li><a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;module=MEMBERS&amp;action=MODIFY&amp;object=<!-- TMPL_VAR NAME="borrowernumber" -->">Modification Log</a></li><!-- /TMPL_IF -->
</ul></div>
<!-- /TMPL_IF -->

