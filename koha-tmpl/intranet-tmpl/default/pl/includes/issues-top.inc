<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<!--Authored by rachel@katipo.co.nz 104:38 1/11/99-->
<!--updated by rachel@katipo.co.nz 01:02 5/11/99-->

<html>
<head>
<title>KOHA: INTRANET: Wypożyczenia i Zwroty</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

</head>
<body text="black" bgcolor="white" link="#0000ff" vlink="#0000ff" "3366cc" Alink="#cc3300"
marginheight=0 marginwidth=0 leftmargin=0 topmargin=0 >



<!--HDL Colours

	Yellow = ffcc00
	light blue = ccccff
	bright blue links = 0000ff
	aubergine = 663266
	light green/grey = cccc99


-->

<!------------------------MENUS-------------------------------->

<table cellpadding=0 cellspacing=0 width="100%" border=0>
	<tr valign=top bgcolor=ffcc00  >
		<td COLSPAN=3>
			<table cellpadding=0 cellspacing=0  border=0 height=29>
				<tr valign=top bgcolor=ffcc00>
					<td background="<!-- TMPL_VAR name="themelang" -->/images/issues-spot-1.gif" width="224" height="29">
						<font size=1 face="arial">
						<img src="<!-- TMPL_VAR name="themelang" -->/images/holder.gif" width=210 height=4 alt=" " hspace=0 vspace=0>
						<br>
						<img src="<!-- TMPL_VAR name="themelang" -->/images/holder.gif" width=35 height=21 align=left alt=" " hspace=0 vspace=0>
						KOHA: <A HREF="/cgi-bin/koha/mainpage.pl">HDL INTRANET</A>
						<br>
						<img src="<!-- TMPL_VAR name="themelang" -->/images/holder.gif" width=210 height=1 alt=" " hspace=0 vspace=0>
						</FONT>
					</td>
				</TR>
			</TABLE>
		</TD>
		<TD COLSPAN=3 align=right>
			<font size=1 face="arial" color="white">I 1 &nbsp; &nbsp; </font>
		</TD>
	</tr>
	<TR VALIGN=TOP BGCOLOR="ffcc00">
		<TD  COLSPAN=6>
			<img src="<!-- TMPL_VAR name="themelang" -->/images/holder.gif"  WIDTH=1  HEIGHT=12  HSPACE=0 vspace=0>
		</TD>
	</TR>
	<tr valign=top bgcolor=ffcc00>
		<TD>
			<img src="<!-- TMPL_VAR name="themelang" -->/images/holder.gif" width=35 height=21 align=left alt=" " hspace=0 vspace=0>
		</TD>
		<td>
			<font size=2>
			<form action=/cgi-bin/simple-redirect.pl method=post>
			<select>

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=57>WYPOŻYCZENIA & ZWROTY
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-) Wypożyczenia
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reporty

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Wypożycznia Dziś
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Wypożyczenia w Tym Tygodniu
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Wypożyczenia w tym Miesiącu

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Zwroty
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reporty

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Zwroty dziś
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Zwroty w tym tygodniu
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Zwroty w tym miesiacu


			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Przedłużenia
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reporty
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Przedłużenia dziś
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Przedłużenia w tym tygodniu
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Przedłużenia w tym miesiącu



			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Zaległe Książki
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Zaległe dziś
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Otrzymane środki
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Dziś
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Bieżący tydzień
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Bieżący Miesiąc
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Bieżący rok

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Zagubione Książki
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reporty

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Zagubienia w tym miesiącu
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Zagubienia w tym roku

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Raporty Zaawansowane
			</select>
			</form>
		</TD>
		<TD>
			<font size=2>

			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=57>KATALOG
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Szukaj

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Full Add New

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Bibliografia
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Dodaj

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Modyfikuj
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Wymaż
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reporty
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Zmiany w tym tygodniu
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Zmiany w tym miesiącu
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Zmiany w tym roku

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Items
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Dodaj

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Modyfikuj
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Wymaż
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reporty
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Zmiany w tym tygodniu
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Zmiany w tym miesiącu
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Zmiany w tym roku

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Stock Reports
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Levin
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Książki
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Książki &quot;mówiące&quot;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Video
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Shanon
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Książki
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Książki &quot;mówiące&quot;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Video
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Foxton
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Książki
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Książki &quot;mówiące&quot;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Video
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------


			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Raporty Zaawansowane
			</select>
			</form>
		</TD>
		<TD>
			<font size=2>

			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=57>AKWIZYCJE
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Zamówienia
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Zamów Książki
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Zamów Wydawnictwa Ciągłe
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Zamów Inne
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Anuluj Zamówienie
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reporty
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Zamówione w tym tygodniu
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Zamówione w tym miesiącu
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Zamówione w tym roku
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Dostawcy
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Szczegóły o dostawcy
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Zamówione u dostawcy
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Zasoby dostawcy

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Amazon.com
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Whitcoulls CD
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Whitcoulls Website

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Doręczenia
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Akceptuj Doręczenie
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reporty

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Dostarczono w tym misiącu
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Doręczenia w tym roku
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Budget
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Budżet książkowy 1
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Bieżący Miesiąc
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Od Pocz. Roku
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Budżet książkowy 2
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Bieżący Miesiąc
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Od Pocz. Roku

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Budżet książkowy 4
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Bieżący Miesiąc
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Od Pocz. Roku

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Budżet książkowy 5
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Bieżący Miesiąc
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Od Pocz. Roku

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Budżet łącznie
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Bieżący Miesiąc
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Od Pocz. Roku
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Raporty Roczne
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Zobowiązania na Natępny Rok


			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Raporty Zaawansowane
			</select>
			</form>
		</TD>
		<TD>
			<font size=2>

			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=57">CZYTELNICY
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-> Nowy Czytelnik
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Ustawienia
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Check if Expired
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Strategia
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Reporty

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - - Suma czytelników
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - - Nowe w tym tygodniu
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - - Nowe w tym miesiącu
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - - Nowe w tym roku

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-----------------------------------
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">->  Borrower Enquiry
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Wszystkie wypożyczone
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Zaległe
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Historia
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Komunikaty
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Reporty
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - - ŚREDNIA WYPOŻYCZEŃ
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Suma wypożyczeń

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-----------------------------------
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-> Raporty Zaawansowane
			</select>
			</form>
		</TD>
		<TD>
			<font size=2>
			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=57">INNE
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-> OPAC
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Szukaj w katalogu

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Przedłużanie Książek
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Szczegóły o czytelniku
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Aktualizuj Szczegóły

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-----------------------------------
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-> Zasoby
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Fundview CD

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-----------------------------------
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43"> -> Witryna Biblioteki

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-----------------------------------
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43"> -> Koniec Roku
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Inwentaryzacja
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Ustal nowy budget
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Audit Reports
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-----------------------------------
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43"> -> Pomoc
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Telnet Pomoc
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Pomoc Intranet
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Pomoc o szukaniu

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43"> -> Raporty Zaawansowane
			</select>
			</form>
		</td>
	</tr>
	<tr valign=top bgcolor=ffcc00 >
		<TD COLSPAN=4>&nbsp;</TD>
		<td  ALIGN=RIGHT COLSPAN=2 >
			<table cellpadding=0 cellspacing=0  border=0 height=29>
				<tr valign=top bgcolor=ffcc00 >
					<td background="<!-- TMPL_VAR name="themelang" -->/images/issues-spot-2.gif" width="235" height="29"  ALIGN=RIGHT >
						<font size=1 face="arial">
						<img src="<!-- TMPL_VAR name="themelang" -->/images/holder.gif" width=223 height=12 alt=" " hspace=0 vspace=0>
						<br>
						<img src="<!-- TMPL_VAR name="themelang" -->/images/holder.gif" width=26 height=17 align=right alt=" " hspace=0 vspace=0>jesteś w <A HREF="index.html">WYPOŻYCZENIA I ZWROTY</a><br>
						<img src="<!-- TMPL_VAR name="themelang" -->/images/holder.gif" width=223 height=1 alt=" " hspace=0 vspace=0></FONT>
					</td>
				</TR>
			</TABLE>
		</TD>
	</tr>
	<TR VALIGN=TOP BGCOLOR="000000">
		<TD  COLSPAN=6>
			<img src="<!-- TMPL_VAR name="themelang" -->/images/blackdot.gif"  WIDTH=1  HEIGHT=2  HSPACE=0 vspace=0>
		</TD>
	</TR>
</table>
<BLOCKQUOTE>
<!-- TMPL_IF NAME="loggedinusername" -->
    <p align=left>Zalogowano jako: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Wyloguj</a>]</p>
<!-- TMPL_ELSE -->
    <p align=left><a href="/cgi-bin/koha/opac-user.pl">Zaloguj do</a> Systemu Koha</p>
<!-- /TMPL_IF -->
