<!-- TMPL_IF NAME="opacheader" --><!-- TMPL_VAR name="opacheader" --><!-- /TMPL_IF -->
<div id="masthead">
<h1><!-- TMPL_IF NAME="opacsmallimage" --><img alt="<!-- TMPL_VAR NAME="LibraryName" -->" src="<!-- TMPL_VAR NAME="opacsmallimage" -->" /><!-- /TMPL_IF -->Пошук у каталозі бібліотеки</h1>
<div class="menu"><a href="/cgi-bin/koha/opac-main.pl">Домівка ЕК</a> <!-- TMPL_IF NAME="opacbookbag" -->| <a href="" onclick="openBasket(); return false;" title="&quot;Кошик&quot; для Вашої підбірки">Бібліотечне замовлення<span id="basket"><script language="javascript" type="text/javascript">if(basketcount){ document.write(basketcount) };</script></span></a><!-- /TMPL_IF --></div><br class="clear">

<!-- TMPL_IF NAME="opacuserlogin" --><!-- TMPL_IF NAME="loggedinusername" --><div id="members">
	<ul>
		<li>Зареєстровано як  <span class="loggedinusername"><!-- TMPL_LOOP NAME="USER_INFO" --><!-- TMPL_VAR NAME="title" --> <!-- TMPL_VAR NAME="firstname" --> <!-- TMPL_VAR NAME="surname" --><!-- /TMPL_LOOP --></span></li>
		<!--TMPL_IF NAME="virtualshelves" --><li><a href="/cgi-bin/koha/opac-shelves.pl">Мої віртуальні полиці</a></li><!-- /TMPL_IF -->
		<li><a href="/cgi-bin/koha/opac-user.pl">Моя облікова скринька</a></li>
		<li><a class="logout" href="/cgi-bin/koha/opac-logout.pl">Вийти</a></li>
	</ul>	
</div>
<!-- TMPL_ELSE -->
	<div id="members">
		<a class="card" href="/cgi-bin/koha/opac-user.pl">Ввійти, щоб отримати <br /> можливості власника квитка</a>
	</div>
<!-- /TMPL_IF -->
<br class="clear" /><!-- /TMPL_IF -->
</div>
