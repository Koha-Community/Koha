	<!-- MENUS -->
	<div id="menuline" style="font-size:11pt;margin-top:20px;margin-bottom:20px;padding-left:0px;">
		<a href='javascript:delBasket()' class="menu">Vider</A> <a href='javascript:delSelRecords()' class="menu">Enlever sélection</A> <a href='javascript:sendBasket()' class="menu">Envoyer</A> <a href='javascript:printBasket()' class="menu">Imprimer</A> <a href='javascript:quit()' class="menu">Fermer</A>
		<!-- TMPL_IF NAME="verbose" -->
			<a href="javascript:showLess()" class="menu">Résumé</a>
		<!-- TMPL_ELSE -->
			<a href="javascript:showMore()" class="menu">Détails</a>
		<!-- /TMPL_IF -->

	</div>
