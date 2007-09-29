<div id="toolbar"><ul class="toolbar">
	<li><a href="/cgi-bin/koha/circ/circulation.pl?findborrower=<!-- TMPL_VAR NAME="borrowernumber" -->">Check Out</a></li>
	<!-- TMPL_IF name="adultborrower" --><li><a href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;guarantorid=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;category_type=C">Add child</a></li><!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="category_type" -->
            <!--TMPL_IF NAME="guarantor"-->
                <li><a href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;guarantorid=<!-- TMPL_VAR NAME="guarantorborrowernumber" -->&amp;category_type=<!-- TMPL_VAR NAME="category_type"-->">
            <!--TMPL_ELSE-->
            <li><a href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;category_type=<!-- TMPL_VAR NAME="category_type"-->">
            <!--/TMPL_IF-->Edit</a></li>
        <!-- TMPL_ELSE --> <!-- try with categorycode if no category_type -->
            <!-- TMPL_IF NAME="categorycode" -->
            <li><a href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;categorycode=<!-- TMPL_VAR NAME="categorycode"-->">Edit</a></li>
            <!-- TMPL_ELSE --> <!-- if no categorycode, set category_type to A by default -->
                <li><a href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;category_type=A">Edit</a></li>
            <!-- /TMPL_IF -->
        <!-- /TMPL_IF -->
	<li><a href="Someone please write this">Add Note</a></li>
	<li><a href="/cgi-bin/koha/members/member-password.pl?member=<!-- TMPL_VAR NAME="borrowernumber" -->">Change Password</a></li>
	<li><a href="">Print</a><ul><li><a href="">Page</a></li><li><a href="">Slip</a></li></ul></li><li><a href="javascript:confirm_reregistration();">Renew Account</a></li><li><a href="/cgi-bin/koha/members/member-flags.pl?member=<!-- TMPL_VAR NAME="borrowernumber" -->">Set Permissions</a></li><li><a href="javascript:confirm_deletion();">Delete</a></li>
</ul>
<br clear="all" /></div>
