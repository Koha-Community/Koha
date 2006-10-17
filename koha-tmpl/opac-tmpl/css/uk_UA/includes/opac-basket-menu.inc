	<!-- MENUS -->
	<div id="menuline" style="font-size:11pt;margin-top:20px;margin-bottom:20px;padding-left:0px;">
		<a href='javascript:delBasket()' class="menu">Спорожнити</A> <a href='javascript:delSelRecords()' class="menu">Видалити вибране</A> <a href='javascript:sendBasket()' class="menu">Надсилання</A> <a href='javascript:printBasket()' class="menu">Друк</A> <a href='javascript:quit()' class="menu">Закрити</A>
		<!-- TMPL_IF NAME="verbose" -->
			<a href="javascript:showLess()" class="menu">Зведення</a>
		<!-- TMPL_ELSE -->
			<a href="javascript:showMore()" class="menu">Деталі</a>
		<!-- /TMPL_IF -->

	</div>
