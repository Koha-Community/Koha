<div id="toolbar"><ul class="toolbar">
	<li><a href="/cgi-bin/koha/circ/circulation.pl?findborrower=<!-- TMPL_VAR NAME="cardnumber" -->">Prêt</a></li>
	<!-- TMPL_IF name="adultborrower" --><li><a href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;guarantorid=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;category_type=C">Ajouter un enfant</a></li><!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="category_type" -->
            <!--TMPL_IF NAME="guarantor"-->
                <li><a href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;guarantorid=<!-- TMPL_VAR NAME="guarantorborrowernumber" -->&amp;category_type=<!-- TMPL_VAR NAME="category_type"-->">
            <!--TMPL_ELSE-->
            <li><a href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;category_type=<!-- TMPL_VAR NAME="category_type"-->">
            <!--/TMPL_IF-->Modifier</a></li>
        <!-- TMPL_ELSE --> <!-- try with categorycode if no category_type -->
            <!-- TMPL_IF NAME="categorycode" -->
            <li><a href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;categorycode=<!-- TMPL_VAR NAME="categorycode"-->">Modifier</a></li>
            <!-- TMPL_ELSE --> <!-- if no categorycode, set category_type to A by default -->
                <li><a href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;category_type=A">Modifier</a></li>
            <!-- /TMPL_IF -->
        <!-- /TMPL_IF -->
	<li><a href="Someone please write this">Ajouter note</a></li>
	<li><a href="/cgi-bin/koha/members/member-password.pl?member=<!-- TMPL_VAR NAME="borrowernumber" -->">Changer mot de passe</a></li>
	<li><a href="">Imprimer</a><ul><li><a href="">Pages</a></li><li><a href="">Ticket</a></li></ul></li><li><a href="javascript:confirm_reregistration();">Renouveler compte</a></li><!-- TMPL_IF NAME="CAN_user_permission" --><li><a href="/cgi-bin/koha/members/member-flags.pl?member=<!-- TMPL_VAR NAME="borrowernumber" -->">Définir permissions</a></li><!-- /TMPL_IF --><li><a href="javascript:confirm_deletion();">Supprimer</a></li>
</ul>
<br clear="all" /></div>
