	<!-- MENUS -->
	<div id="menuline" style="font-size:11pt;margin-top:20px;margin-bottom:20px;">
		<span class="spacer">&nbsp;</span>
		<A href='javascript:delBasket()' class="menu">Empty</A>
		<span class="basketspacer">&nbsp;</span>
		<A href='javascript:delSelRecords()' class="menu">Remove selection</A>
		<span class="basketspacer">&nbsp;</span>
		<A href='javascript:sendBasket()' class="menu">Send</A>
		<span class="basketspacer">&nbsp;</span>
		<A href='javascript:printBasket()' class="menu">Print</A>
		<span class="basketspacer">&nbsp;</span>
		<A href='javascript:quit()' class="menu">Close</A>
		<!-- TMPL_IF NAME="verbose" -->
			<a href="javascript:showLess()" class="menu">Brief Display</a>
		<!-- TMPL_ELSE -->
			<a href="javascript:showMore()" class="menu">More Details</a>
		<!-- /TMPL_IF -->

	</div>
