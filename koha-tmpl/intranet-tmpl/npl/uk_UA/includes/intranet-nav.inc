<div id="nav">
<ul>
				<li><h4>Коха</h4></li>

				<li><a href="/cgi-bin/koha/mainpage.pl">Домівка інтерфейсу бібліотекаря у Коха</a></li>
				<li><a href="/cgi-bin/koha/circ/circulation.pl">Обіг</a><ul><li><a href="/cgi-bin/koha/circ/circulation.pl">Видачі</a>	<form method="post" action="/cgi-bin/koha/circ/circulation.pl">
<label for="navfindborrower"> <span class="accesskey">u</span> Видано: </label>
				<input id="navfindborrower" name="findborrower" type="text" size="10" accesskey="u" />
				<input type="hidden" name="branch" value="<!-- TMPL_VAR name="branch" -->" />
				<input type="hidden" name="printer" value="<!-- TMPL_VAR name="printer" -->" />
				<input type="submit" class="submit" value="Виконати">
	</form></li><li><a accesskey="r" href="/cgi-bin/koha/circ/returns.pl"><span class="accesskey">R</span> Повернення</a>
</li>
<li><a href="/cgi-bin/koha/circ/reserve.pl">Список резервувань</a></li>
<li><a href="/cgi-bin/koha/circ/branchtransfers.pl">Переміщення</a></li>
</ul></li>
				<li><a href="/cgi-bin/koha/members/members-home.pl">Відвідувачі</a><ul><li><form action="/cgi-bin/koha/members/member.pl" method="post">
	<label for="navmember">Шукати: </label><input id="navmember" type="text" size="10" name="member" />
	<input type="submit" value="Пошук" class="submit">

	</form></li></ul></li>
				<li><a href="/cgi-bin/koha/loadmodules.pl?module=search&amp;marc=1&amp;type=intranet">Каталог</a><ul><li><form method="post" action="/cgi-bin/koha/search.marc/search.pl"><input type="hidden" name="op" value="do_search" /><input type="hidden" name="type" value="intranet" /><input type="hidden" name="nbstatements" value="3" /><label for="navkeyword"><span class="accesskey">Q</span> Простий пошук: </label><input type="hidden" name="marclist" value="" /><input type="hidden" name="and_or" value="and" /><input type="hidden" name="excluding" value="" /><input type="hidden" name="operator" value="contains" /><input type="text" id="navkeyword" name="value" size="10" accesskey="q" /><input type="submit" value="Почати пошук" class="submit"></form></li>
</ul></li>
<li><a href="/cgi-bin/koha/acqui.simple/addbooks.pl">Каталогізація</a><ul>
<li><a href="/cgi-bin/koha/acqui.simple/addbiblio.pl">Додати МАРК-запис</a></li>
<li><a href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Надходження</a></li>
<li><a href="/cgi-bin/koha/authorities/authorities-home.pl">Авторитетні джерела</a></li>
<li><a href="/cgi-bin/koha/bull-home.pl">Періодичні видання</a></li>
<li><a href="/cgi-bin/koha/bookshelves/shelves.pl">Віртуальні полиці</a></li></ul></li>
<li><a href="/cgi-bin/koha/reports-home.pl">Облік та звіти</a></li>
<li><a href="/cgi-bin/koha/admin-home.pl">Керування Коха</a>
<ul><li><a href="/cgi-bin/koha/admin-home.pl">Керування системою</a></li>
<li><a href="/cgi-bin/koha/admin/systempreferences.pl">Системні налаштування</a></li></ul>
</li><li><a href="/cgi-bin/koha/about.pl">Про Коха</a></li>
<!-- TMPL_IF NAME="loggedinusername" --><li>
    Зайдено у систему як: <!-- TMPL_VAR NAME="loggedinusername" --> <ul><li><a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Вийти</a></li></ul></li><!-- /TMPL_IF -->
<!-- TMPL_IF NAME="IntranetNav" --><!-- TMPL_VAR NAME="IntranetNav" --><!-- /TMPL_IF -->
</ul>
</div>
