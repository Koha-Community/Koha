<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html401/loose.dtd">

<html>
<head>
<title>KOHA: INTRANET: Parameters</title>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">

<style>

td.about {
	padding:4px;
	}
td.about a {
	background-color: #86c268;
	font-weight: normal;
	text-decoration: none;
	cursor: hand;
	color: #FFFFFF;
	font-weight: bold;
	}
td.about a:hover {
	background-color: #86c268;
	color: #FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	}
</style>


</head>
<body text="black" bgcolor="white" link="#0000ff" vlink="#0000ff" Alink="#cc3300"
marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>


<!------------------------MENUS-------------------------------->
<table cellpadding=0 cellspacing=0 width="100%" border=0>
<tr height="45">
	<td valign="bottom" align="left">
		<table bgcolor="#dddddd" width="100%" cellpadding=0 cellspacing=0>
		<tr>
			<td>
			<div id="menubar">
			<table cellpadding=0 cellspacing=0  border=0 height=29 width="70%">
				<tr>
					<td class="koha"><b lang=mi>KOHA</b></td>
					<td class=home>
						<a href="/cgi-bin/koha/mainpage.pl">返回主頁</a>
					</td>
					<td class=catalogue>
						<a href="/cgi-bin/koha/loadmodules.pl?module=search&type=intranet">館藏查詢</a>
					</td>
					<td class=members>
						<a href="/cgi-bin/koha/members-home.pl">讀者帳戶</a>
					</td>
					<td class=acquisition>
						<a href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">書藉購置</a>
					</td>
					<td class=circulation>
						<a  href="/cgi-bin/koha/circ/circulation.pl">流通服務</a>
					</td>
					<td class=reports>
						<a href="/cgi-bin/koha/reports-home.pl">報表列印</a>
					</td>
					<td class=parameters>
						<a href="/cgi-bin/koha/admin-home.pl">系統設定</a>
					</td>
					<td class=about>
						<a href="/cgi-bin/koha/about.pl">關於<span lang=mi>Koha</span></a>
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
    <p align=left>使用者身分：<span class=en><!-- TMPL_VAR NAME="loggedinusername" --></span> [<a href=/cgi-bin/koha/mainpage.pl?logout.x=1>登出</a>]</p>
<!-- TMPL_ELSE -->
    <p align=left><a href=/cgi-bin/koha/opac-user.pl>登入</a><span lang=mi>Koha</span></p>
<!-- /TMPL_IF -->
