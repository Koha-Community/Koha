	<!-- MENUS -->
	<div id="menuline" style="font-size:11pt;margin-top:20px;margin-bottom:20px;padding-left:0px;">
		<a href='javascript:delBasket()' class="menu">Vuoto</A> <a href='javascript:delSelRecords()' class="menu">Rimozione selezione</A> <a href='javascript:sendBasket()' class="menu">Invio</A> <a href='javascript:printBasket()' class="menu">Stampa</A> <a href='javascript:quit()' class="menu">Chiusura</A>
		<!-- TMPL_IF NAME="verbose" -->
			<a href="javascript:showLess()" class="menu">Riassunto</a>
		<!-- TMPL_ELSE -->
			<a href="javascript:showMore()" class="menu">Dettagli</a>
		<!-- /TMPL_IF -->

	</div>
