<!doctype html public "-//w3c//dtd html 4.0 transitional//en">

<html>
<head>
<title>KOHA：INTRANET：流通</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

<script language="JavaScript">
<!-- Hide from old browsers
function openWindow(targeturl, windowname) {
newwin =
window.open(targeturl,windowname,"height=480,width=640,scrollbars,resizable")
}
function focusOnFirst (){
document.forms[0].elements[0].focus();
}
// end hiding -->
</script>

<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<style>
a.circulation {
	font-weight: normal;
	text-decoration: none;
	background-color: #be6170;
	cursor: hand;
	color:#FFFFFF;
	padding:4px;
	font-weight: bold;
	}
a.circulation:hover {
	background-color: #be6170;
	color: #FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	}
</style>
</head>
<body text="black" bgcolor="white" link="#0000ff" vlink="#0000ff" "3366cc" Alink="#cc3300"
marginheight=0 marginwidth=0 leftmargin=0 topmargin=0 onLoad="javascript:focusOnFirst()">

<!------------------------MENUS-------------------------------->
<table cellpadding=0 cellspacing=0 width="100%" border=0>
<tr height="65">
	<td valign="bottom" align="left">
		<table width="100%" cellpadding=0 cellspacing=0>
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
			<table cellpadding=0 cellspacing=0  border=0 height=29>
				<tr>
					<td width="100"></td>
					<td><b>選項 &gt;&gt;　</b></td>
					<td>
						<a href="/cgi-bin/koha/circ/circulation.pl" class="submenu">借出</a>
					</td>
					<td>
						<a href="/cgi-bin/koha/circ/returns.pl" class="submenu2">還書</a>
					</td>
					<td>
						<a href="/cgi-bin/koha/circ/branchtransfers.pl" class="submenu">Branch transfers</a>
					</td>
				</tr>
			</table>
			</div>
		</td></tr></table>
	</TD>
</tr>
</table>
<BLOCKQUOTE>
<!-- TMPL_IF NAME="loggedinusername" -->
    <p align=left>目前身份：<!-- TMPL_VAR NAME="loggedinusername" --> 【<a href=/cgi-bin/koha/mainpage.pl?logout.x=1>登出</a>】</p>
<!-- TMPL_ELSE -->
    <p align=left><a href=/cgi-bin/koha/opac-user.pl>登入</a> Koha</p>
<!-- /TMPL_IF -->
