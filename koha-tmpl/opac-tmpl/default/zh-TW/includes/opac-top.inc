<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>KOHA：查詢館藏</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/opac.css">
</head>

<body>



<!-- MENUS -->

<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr bgcolor="#339999">

	<td width="7%">
		<img src="<!-- TMPL_VAR name="themelang" -->/images/front-background-small.gif" height="50" border="0" alt=""><b>KOHA</b>
	</td>
        <td width="10%">
		<a href="/cgi-bin/koha/opac-search.pl" title="查詢館藏" class="white">
			查詢
		</a>
	</td>
        <td width="10%">
		<a href="/cgi-bin/koha/opac-user.pl" title="辦理讀者登記手續" class="white">
			讀者登記
		</a>
	</td>
	<td align="left" width="10%">
		<a href="/cgi-bin/koha/opac-main.pl" title="返回首頁" class="white">返回首頁</a>
	</td>
	<td width="60%">
		&nbsp;
	</td>
        </tr>
</table>

<!-- MAIN BODY OF PAGE -->

<!-- TMPL_IF NAME="loggedinusername" -->
    <p align="left">目前身份：<!-- TMPL_VAR NAME="loggedinusername" --> 【<a href="/cgi-bin/koha/opac-user.pl">個人主頁</a>】【<a href="/cgi-bin/koha/opac-main.pl?logout.x=1">登出</a>】</p>
<!-- TMPL_ELSE -->
    <p align="left"><a href="/cgi-bin/koha/opac-user.pl">登入</a> Koha</p>
<!-- /TMPL_IF -->

