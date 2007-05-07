<!-- TMPL_IF NAME="opacheader" --><!-- TMPL_VAR name="opacheader" --><!-- /TMPL_IF -->
<div id="masthead">
<h1><!-- TMPL_IF NAME="opacsmallimage" --><img alt="<!-- TMPL_VAR NAME="LibraryName" -->" src="<!-- TMPL_VAR NAME='opacsmallimage' -->" /><!-- /TMPL_IF -->Пошук у каталозі бібліотеки</h1>
<div class="menu"><form action="/cgi-bin/koha/opac-search.pl" method="post">
<p><a href="/cgi-bin/koha/opac-main.pl">Домівка ЕК</a> <!-- TMPL_IF NAME="opacbookbag" -->| <a href="" onclick="openBasket(); return false;" title="&quot;Кошик&quot; для Вашої підбірки">Бібліотечне замовлення</a><!-- /TMPL_IF --></p> <p><label for="value">Шукати у каталозі</label>
  <input type="hidden" name="op" value="do_search" />
			<input type="hidden" name="type" value="opac" />
			<input type="hidden" name="marclist" value="" />
			<input type="hidden" name="and_or" value="and" />
			<input type="hidden" name="excluding" value="" />
			<input type="hidden" name="operator" value="contains" />
			<input type="text" size="12" name="value" id="value" />&nbsp;<input type="submit" class="submit" name="Go" value="Пошук"></form></p></div>
<!-- <div class="menu"><a href="/cgi-bin/koha/opac-user.pl">your library home</a> |   
	<a href="/cgi-bin/koha/opac-userdetails.pl">your personal details</a> | <a href="/cgi-bin/koha/opac-shelves.pl">My Virtual Shelves</a> | <a class="logout" href="/cgi-bin/koha/opac-logout.pl">log out</a>
  </ul>
</div> -->
<!-- TMPL_IF NAME="loggedinusername" --><div id="members">
	<ul>
		<li>Зареєстровано як  <span class="loggedinusername"><!-- TMPL_LOOP NAME="USER_INFO" --><!-- TMPL_VAR NAME="title" --> <!-- TMPL_VAR NAME="firstname" --> <!-- TMPL_VAR NAME="surname" --><!-- /TMPL_LOOP --></span></li>
		<!--TMPL_IF NAME="virtualshelves" --><li><a href="/cgi-bin/koha/opac-shelves.pl">Мої віртуальні полиці</a></li><!-- /TMPL_IF -->
		<li><a href="/cgi-bin/koha/opac-user.pl">Моя облікова скринька</a></li>
		<li><a class="logout" href="/cgi-bin/koha/opac-logout.pl">Вийти</a></li>
	</ul>	
<br class="clear" />
</div>
<!-- TMPL_ELSE -->
	<div id="members">
		<a class="card" href="/cgi-bin/koha/opac-user.pl">Ввійти, щоб отримати <br /> можливості власника квитка</a>
<br class="clear" />
	</div>
<!-- /TMPL_IF -->
</div>
