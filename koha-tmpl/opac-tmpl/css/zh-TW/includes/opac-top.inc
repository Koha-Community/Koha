<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<!-- TMPL_IF name="opacstylesheet" -->
		<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="opacstylesheet"-->" />
	<!-- TMPL_ELSE -->
		<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang"-->/includes/opac.css" />
	<!-- /TMPL_IF -->
	<title><!--TMPL_VAR name="LibraryName"--></title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/includes/basket.js"></script>
	<script language="JavaScript" type="text/javascript">
		function _(s) { return s } // dummy function for gettext
		//
	</script>
	<script type="text/javascript" language="javascript">
	var MSG_BASKET_EMPTY = _("書籃是空的");
	var MSG_RECORD_IN_BASKET = _("這個書目已在書籃內");
	var MSG_RECORD_ADDED = _("書目已放在書籃內");
	var MSG_NRECORDS_ADDED = _("個書目成功新增");
	var MSG_NRECORDS_IN_BASKET = _("已在書籃內");
	var MSG_NO_RECORD_SELECTED = _("未有點選書目");
	var MSG_NO_RECORD_ADDED = _("沒有新增書目記錄");
	function Dopop(link) {
		newin=window.open(link,'popup','width=500,height=400,toolbar=false,scrollbars=yes');
	}
	</script>
</head>
<body>
	<!-- MENUS -->
	<div id="menuline">
		<img src="<!-- TMPL_VAR name="themelang" -->/images/front-background-small.gif" height="50" alt="Koha標誌" style="float: left">
		<div class="SmallLibraryName"><!--TMPL_VAR name="LibraryName"--></div>
		<span class="spacer">&nbsp;</span>
		<span class="spacer">&nbsp;</span>
		<a class="menu" href="/cgi-bin/koha/opac-main.pl" title="Koha首頁">返回首頁</a>
		<span class="spacer">&nbsp;</span>
		<a class="menu" href="/cgi-bin/koha/opac-search.pl" title="進階查詢">進階查詢</a>
		<span class="spacer">&nbsp;</span>
		<a class="menu" href="/cgi-bin/koha/opac-user.pl" title="個人首頁">個人主頁</a>
		<span class="spacer">&nbsp;</span>
		<a class="menu" href="javascript:openBasket()" title="書籃">書籃 <span id="basket"><script language="javascript" type="text/javascript">if(basketcount){ document.write(basketcount) };</script></span></a>
	</div>
	<!-- MAIN BODY OF PAGE -->
