<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<!--Authored by rachel@katipo.co.nz 104:38 1/11/99-->
<!--updated by rachel@katipo.co.nz 01:02 5/11/99-->

<html>
<head>
<title>KOHA: INTRANET: Prêts & Retours</title>

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

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=57>PRETS & RETOURS
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-) Prêts
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reports

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - -  Prêts Today
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - -  Prêts This Week
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - -  Prêts This Mois

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Retours
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reports

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Retours Today
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Retours This Week
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Retours This Mois


			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Renouvellements
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reports
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Renouvellements Today
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Renouvellements This Week
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Renouvellements This Mois



			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Signaler retard Books
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Signaler retard Today
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Money Reçu
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Today
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - This Week
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - This Mois
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - This Année

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Perdu Books
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reports

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Perdu This Mois
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Perdu This year

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Advanced Reports
			</select>
			</form>
		</TD>
		<TD>
			<font size=2>

			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=57>CATALOGUE
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Search

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Full Add New

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Bibliography
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Add

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Modifier
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Delete
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reports
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Changes this week
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Changes this month
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Changes this year

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Ouvrages
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Add

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Modifier
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Delete
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reports
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Changes this week
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Changes this month
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Changes this year

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Stock Reports
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Levin
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Books
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Talking Books
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Videos
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Shanon
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Books
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Talking Books
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Videos
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Foxton
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Books
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Talking Books
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Videos
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------


			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Advanced Reports
			</select>
			</form>
		</TD>
		<TD>
			<font size=2>

			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=57>ACQUISITIONS
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Orders
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Commande Books
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Commande Serials
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Commande Other
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Annuler Commande
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reports
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Ordered This Week
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Ordered This Mois
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Ordered This year
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Suppliers
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Supplier Details
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - On Commande with Supplier
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Supplier Resources

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Amazon.com
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Whitcoulls CD
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Whitcoulls Site Web

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Deliveries
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Accept Delivery
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reports

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Delivered This Mois
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Delivered This year
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Budget
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Book Budget 1
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - This Mois
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Année to Date
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Book Budget 2
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - This Mois
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Année to Date

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Book Budget 4
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - This Mois
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Année to Date

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Book Budget 5
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - This Mois
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Année to Date

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Total Budget
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - This Mois
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Année to Date
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - End Of Année Reports
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Next Years Commitment


			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Advanced Reports
			</select>
			</form>
		</TD>
		<TD>
			<font size=2>

			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=57>EMPRUNTEURS
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> New Emprunteur
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Setup
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Check if Expired
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Policy
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reports

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Total Borrowers
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - New This Week
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - New This Mois
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - New This Année

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Emprunteur Enquirey
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - All Books Out
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Overdues
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - History
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Messages
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Reports
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Average Borrowings		<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Total Borrowings

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Advanced Reports
			</select>
			</form>
		</TD>
		<TD>
			<font size=2>
			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=57>AUTRE
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> OPAC
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Recherche Catalogue

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Renouveler Books
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Lecteur Details
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Mettre à jour Details

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Resources
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Fundview CD

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43> ->  Library Site Web

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43> ->  End sur Année
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Stocktake
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Set New Budgets
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Audit Reports
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43> ->  Help
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Telnet Help
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Intranet Help
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Searching Help

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43> ->  Advanced Reports
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
						<img src="<!-- TMPL_VAR name="themelang" -->/images/holder.gif" width=26 height=17 align=right alt=" " hspace=0 vspace=0>you are in <A HREF="index.html">PRETS & RETOURS</a><br>
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
    <p align=left>Connecté comme: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href=/cgi-bin/koha/mainpage.pl?logout.x=1>Déconnecter</a>]</p>
<!-- TMPL_ELSE -->
    <p align=left><a href=/cgi-bin/koha/opac-user.pl>S'identifier</a> à Koha</p>
<!-- /TMPL_IF -->
