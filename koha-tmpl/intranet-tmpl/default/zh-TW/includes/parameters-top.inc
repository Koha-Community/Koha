<!doctype html public "-//w3c//dtd html 4.0 transitional//en">

<html>
<head>
<title>KOHA: INTRANET: Parameters</title>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<link rel="stylesheet" type="text/css" href="<TMPL_VAR name="themelang">/includes/common-style.css">
</head>
<body text="black" bgcolor="white" link="#0000ff" vlink="#0000ff" "3366cc" Alink="#cc3300"
marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>

<style>
a.parameters {
	background-color: #86c268;
	font-weight: normal;
	text-decoration: none;
	cursor: hand;
	color: #FFFFFF;
	padding:4px;
	font-weight: bold;
	}
a.parameters:hover {
	background-color: #86c268;
	color: #FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	}
</style>

<!------------------------MENUS-------------------------------->
<table cellpadding=0 cellspacing=0 width="100%" border=0>
<tr height="65">
	<td valign="bottom" align="left">
		<table bgcolor="dddddd" width="100%" cellpadding=0 cellspacing=0>
		<tr>
			<td>
			<div id="menubar">
			<table cellpadding=0 cellspacing=0  border=0 height=29 width=70%>
				<tr>
					<td class="koha"><b>KOHA</b></td>
					<td>
						<a class="home" href="/cgi-bin/koha/mainpage.pl">返回主頁</a>
					</td>
					<td>
						<a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=search&type=intranet">館藏查詢</a>
					</td>
					<td>
						<a class="members" href="/cgi-bin/koha/members-home.pl">讀者帳戶</a>
					</td>
					<td>
						<a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">書藉購置</a>
					</td>
					<td>
						<a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl">流通服務</a>
					</td>
					<td>
						<a class="reports" href="/cgi-bin/koha/reports-home.pl">報表列印</a>
					</td>
					<td>
						<a class="parameters" href="/cgi-bin/koha/admin-home.pl">系統設定</a>
					</td>
					<td>
						<a class="about" href="/cgi-bin/koha/about.pl">有關<span lang=mi>Koha</span></a>
					</td>
				</TR>
			</TABLE>
			</div>
			<div id="submenu" style="border-left:0px;">
			<table cellpadding=0 cellspacing=0  border=0 height=20>
				<tr>
					<td width="100"></td>
					<td><b>選項 &gt;&gt;&nbsp;&nbsp;</b></td>
					<td>
						<a href="/cgi-bin/koha/admin/aqbookfund.pl" class="submenu">Funds</a>
					</td>
					<td>
						<div id="submenu">
						<a href="/cgi-bin/koha/admin/authorised_values.pl" class="submenu">Auth value</a>
						</div>
					</td>
					<td>
						<div id="submenu">
						<a href="/cgi-bin/koha/admin/thesaurus.pl" class="submenu">Thesaurus</a>
						</div>
					</td>
					<td>
						<div id="submenu">
						<a href="/cgi-bin/koha/admin/currency.pl" class="submenu">Currencies</a>
						</div>
					</td>
					<td>
						<div id="submenu">
						<a href="/cgi-bin/koha/admin/printers.pl" class="submenu">Printers</a>
						</div>
					</td>
				</tr>
			</table>
			</div>
		</td></tr></table>
	</TD>
</tr>
</table>
<BLOCKQUOTE>
<TMPL_IF NAME="loggedinusername">
    <p align=left>目前登入為：<TMPL_VAR NAME="loggedinusername"> [<a href=/cgi-bin/koha/mainpage.pl?logout.x=1>登出</a>]</p>
<TMPL_ELSE>
    <p align=left><a href=/cgi-bin/koha/opac-user.pl>登入</a><span lang=mi>Koha</span></p>
</TMPL_IF>
