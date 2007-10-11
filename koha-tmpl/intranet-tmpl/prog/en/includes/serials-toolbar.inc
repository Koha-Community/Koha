<div id="toolbar">
<ul class="toolbar">
	<li><a href="/cgi-bin/koha/serials/subscription-add.pl">New</a></li>
	<!-- TMPL_IF NAME="subscriptionid" --><li><a href="subscription-add.pl?op=mod&amp;subscriptionid=<!-- TMPL_VAR name="subscriptionid" -->">Edit</a></li>
	<li><a href="subscription-add.pl?op=dup&amp;subscriptionid=<!-- TMPL_VAR name="subscriptionid" -->">Duplicate </a></li>
	<li><a href="#" onclick="popup(<!--TMPL_VAR Name="subscriptionid"-->)">Renew </a></li>
	<li><a href="serials-edit.pl?subscriptionid=<!-- TMPL_VAR name="subscriptionid" -->&amp;serstatus=1,3">Receive</a></li>
	<li><a href="javascript:confirm_deletion()">Delete</a></li><!-- /TMPL_IF -->
</ul>
<br clear="all" />    </div>