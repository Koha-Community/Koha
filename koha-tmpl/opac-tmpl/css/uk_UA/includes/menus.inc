	<div id="menuline">
		<!-- TMPL_VAR name="opacnav" --> <a class="menu" href="/cgi-bin/koha/opac-main.pl" title="Library home page">Домівка каталогу</a> <a class="menu" href="/cgi-bin/koha/opac-search.pl" title="Advanced search">Розширений пошук</a>
		<!-- TMPL_IF NAME="loggedinusername" -->
			<!-- TMPL_IF name="virtualshelves" -->
				<a href="/cgi-bin/koha/opac-shelves.pl" class="menu">Віртуальні полиці</a>
			<!-- /TMPL_IF -->
			<!-- TMPL_IF name="suggestion" -->
				<a href="opac-suggestions.pl" class="menu">Пропозиції</a>
			<!-- /TMPL_IF -->
		<!-- /TMPL_IF -->
		<a class="menu" href="/cgi-bin/koha/opac-authorities-home.pl">Заголовки авторитетних джерел</a>
		<!-- TMPL_IF name="opacbookbag" -->
		<a class="menu" href="javascript:openBasket()" title="Кошик бібліотечних записів">Кошик бібліотечних записів <span id="basket"><script language="javascript" type="text/javascript">if(basketcount){ document.write(basketcount) };</script></span></a>
		<!-- /TMPL_IF -->
		<!-- TMPL_IF NAME="loggedinusername" -->
			<a class="menu" href="/cgi-bin/koha/opac-user.pl" title="Member Home page">Особиста сторінка</a> <a class="menu" href="/cgi-bin/koha/opac-main.pl?logout.x=1" title="Logged in as <!-- TMPL_VAR NAME="loggedinusername" -->">Вихід</a>
		<!-- TMPL_ELSE -->
			<a class="menu" href="/cgi-bin/koha/opac-user.pl" title="зареєструйтеся щоб отримати персональні параметри">Реєструватися</a>
		<!-- /TMPL_IF -->
	</div>
