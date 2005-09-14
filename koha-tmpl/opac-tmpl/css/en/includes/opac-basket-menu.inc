	<!-- MENUS -->
	<div id="menuline" style="font-size:11pt;margin-top:20px;margin-bottom:20px;padding-left:0px;">
		<a href='javascript:delBasket()' class="menu">Empty</A>
		<a href='javascript:delSelRecords()' class="menu">Remove selection</A>
		<a href='javascript:sendBasket()' class="menu">Send</A>
		<a href='javascript:printBasket()' class="menu">Print</A>
		<a href='javascript:quit()' class="menu">Close</A>
		<!-- TMPL_IF NAME="verbose" -->
			<a href="javascript:showLess()" class="menu">Brief</a>
		<!-- TMPL_ELSE -->
			<a href="javascript:showMore()" class="menu">Details</a>
		<!-- /TMPL_IF -->

	</div>
