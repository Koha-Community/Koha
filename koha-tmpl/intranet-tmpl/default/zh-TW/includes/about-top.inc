<!doctype html public "-//w3c//dtd html 4.0 transitional//en">

<html>
<head>
<title>KOHA：INTRANET：設定</title>
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

</head>
<body text="black" bgcolor="white" link="#0000ff" vlink="#0000ff" Alink="#cc3300"
marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>

<style>

a.about {
	background-color: #86c268;
	font-weight: normal;
	text-decoration: none;
	cursor: hand;
	color: #FFFFFF;
	padding:4px;
	font-weight: bold;
	}
a.about:hover {
	background-color: #86c268;
	color: #FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	}
</style>

<!------------------------MENUS-------------------------------->
<table cellpadding=0 cellspacing=0 width="100%" border=0>
<tr height="45">
	<td valign="bottom" align="left">
		<table bgcolor="#dddddd" width="100%" cellpadding=0 cellspacing=0>
		<tr>
			<td>
			<div id="menubar">
			<table cellpadding=0 cellspacing=0  border=0 height=29 width=70%>
				<tr>
					<td class="koha"><b>KOHA</b></td>
					<td>
						<a class="home" href="/cgi-bin/koha/mainpage.pl">主頁</a>
					</td>
					<td>
						<a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=search&type=intranet">目錄</a>
					</td>
					<td>
						<a class="members" href="/cgi-bin/koha/members-home.pl">讀者</a>
					</td>
					<td>
						<a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">購置</a>
					</td>
					<td>
						<a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl">流通</a>
					</td>
					<td>
						<a class="reports" href="/cgi-bin/koha/reports-home.pl">報表</a>
					</td>
					<td>
						<a class="parameters" href="/cgi-bin/koha/admin-home.pl">設定</a>
					</td>
					<td>
						<a class="about" href="/cgi-bin/koha/about.pl">關於</a>
					</td>
				</TR>
			</TABLE>
			</div>
		</td></tr></table>
	</TD>
</tr>
</table>
<BLOCKQUOTE>
<!-- TMPL_IF NAME="loggedinusername" -->
    <p align=left>目前身份：<!-- TMPL_VAR NAME="loggedinusername" --> 【<a href=/cgi-bin/koha/mainpage.pl?logout.x=1>登出</a>】</p>
<!-- TMPL_ELSE -->
    <p align=left><a href=/cgi-bin/koha/opac-user.pl>登入</a>Koha</p>
<!-- /TMPL_IF -->
