<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<!--Authored by rachel@katipo.co.nz 104:38 1/11/99-->
<!--updated by rachel@katipo.co.nz 01:02 5/11/99-->

<html>
<head>
<title>KOHA：INTRANET：借出及還書</title>
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

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=57>借出及還書
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-) 借出
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 報表

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 今日借出
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 本週借出
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 本月借出

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> 還書
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 報表

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 今日歸還
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 本週歸還
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 本月歸還


			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> 續借
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 報表
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 今日續借
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 本週續借
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 本月續借



			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> 過期未還書藉
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 今日過期
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 收到款項
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 今日
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 本週
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 本月
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 今年

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> 遺失書藉
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 報表

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 本月遺失
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 今年遺失

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> 進階報表
			</select>
			</form>
		</TD>
		<TD>
			<font size=2>

			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=57>目錄
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> 查詢

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Full Add New

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Bibliography
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 新增

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 修改
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 移除
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 報表
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 本週變更
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 本月變更
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 今年變更

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> 圖書資料項目
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 新增

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 修改
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 移除
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 報表
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 本週變更
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 本月變更
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 今年變更

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> Stock Reports
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- Levin
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 書藉
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 有聲書
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 影碟/影帶
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- Shanon
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 書藉
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 有聲書
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 影碟/影帶
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- Foxton
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 書藉
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 有聲書
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 影碟/影帶
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------


			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> 進階報表
			</select>
			</form>
		</TD>
		<TD>
			<font size=2>

			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=57>購置
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> 訂單
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 訂購書藉
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 訂購期刊
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 訂購其他
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 取消訂單
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 報表
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 本週訂購
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 本月訂購
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 今年訂購
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> 供應商
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 供應商資料
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 已向供應商訂購
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Supplier Resources

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - Amazon.com
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - Whitcoulls 光碟
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - Whitcoulls 網站

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> 交貨
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - Accept Delivery
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 報表

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 本月交貨
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- - 今年交貨
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> 預算案
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 書藉預算案1
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 本月
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Year to Date
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 書藉預算案2
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 本月
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Year to Date

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 書藉預算案4
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 本月
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Year to Date

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 書藉預算案5
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 本月
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Year to Date

			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 預算總額
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 本月
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - - Year to Date
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp; - End Of Year Reports
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>&nbsp; &nbsp;
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>　　- 明年承擔額


			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-----------------------------------
			<option value=/cgi-bin/tododisplay.pl?user=Rachel&todo=43>-> 進階報表
			</select>
			</form>
		</TD>
		<TD>
			<font size=2>

			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=57">讀者
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-> 新增讀者
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">　　- 設定
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Check if Expired
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">　　- 政策
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">　　- 報表

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">　　- - 借書讀者總數
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">　　- - 本週遺失
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">　　- - 本月遺失
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">　　- - 今年遺失

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-----------------------------------
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43>->  Borrower Enquiry
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - All Books Out
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Overdues
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - History
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Messages
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Reports
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - - Average Borrowings
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - - Total Borrowings

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-----------------------------------
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">->  Advanced Reports
			</select>
			</form>
		</TD>
		<TD>
			<font size=2>
			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=57">OTHER
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-> OPAC
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Catalogue Search

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Renew Books
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Member Details
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - - Update Details

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-----------------------------------
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-> Resources
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Fundview CD

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-----------------------------------
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43"> ->  Library Website

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-----------------------------------
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43"> ->  End of Year
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Stocktake
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Set New Budgets
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Audit Reports
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">-----------------------------------
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43"> ->  Help
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Telnet Help
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Intranet Help
			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43">&nbsp; &nbsp; - Searching Help

			<option value="/cgi-bin/tododisplay.pl?user=Rachel&todo=43"> ->  Advanced Reports
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
						<img src="<!-- TMPL_VAR name="themelang" -->/images/holder.gif" width=26 height=17 align=right alt=" " hspace=0 vspace=0>you are in <A HREF="index.html">ISSUES & RETURNS</a><br>
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
    <p align=left>Logged in as: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Log Out</a>]</p>
<!-- TMPL_ELSE -->
    <p align=left><a href="/cgi-bin/koha/opac-user.pl">Log In</a> to Koha</p>
<!-- /TMPL_IF -->
