	<!-- MENUS -->
	<div id="menuline" style="font-size:11pt;margin-top:20px;margin-bottom:20px;">
		<span class="spacer">&nbsp;</span>
		<A href='javascript:delBasket()' class="menu">Svuotare</A>
		<span class="basketspacer">&nbsp;</span>
		<A href='javascript:delSelRecords()' class="menu">Eliminare la selezione</A>
		<span class="basketspacer">&nbsp;</span>
		<A href='javascript:sendBasket()' class="menu">Invia</A>
		<span class="basketspacer">&nbsp;</span>
		<A href='javascript:printBasket()' class="menu">Stampa</A>
		<span class="basketspacer">&nbsp;</span>
		<A href='javascript:quit()' class="menu">Chiudi</A>
		<!-- TMPL_IF NAME="verbose" -->
			<a href="javascript:showLess()" class="menu">Brief Display</a>
		<!-- TMPL_ELSE -->
			<a href="javascript:showMore()" class="menu">More Details</a>
		<!-- /TMPL_IF -->

	</div>
