<div id="toolbar">
<ul class="toolbar">
	<li><a href="/cgi-bin/koha/serials/subscription-add.pl">Nouveau</a></li>
	<!-- TMPL_IF NAME="subscriptionid" --><li><a href="subscription-add.pl?op=mod&amp;subscriptionid=<!-- TMPL_VAR name="subscriptionid" -->">Modifier</a></li>
	<li><a href="subscription-add.pl?op=dup&amp;subscriptionid=<!-- TMPL_VAR name="subscriptionid" -->">Dupliquer </a></li>
	<li><a href="#" onclick="popup(<!--TMPL_VAR Name="subscriptionid"-->)">Renouvellement </a></li>
	<li><a href="serials-edit.pl?subscriptionid=<!-- TMPL_VAR name="subscriptionid" -->&amp;serstatus=1,3">RecevoirReçu</a></li>
	<li><a href="javascript:confirm_deletion()">Supprimer</a></li><!-- /TMPL_IF -->
</ul>
<br clear="all" />    </div>