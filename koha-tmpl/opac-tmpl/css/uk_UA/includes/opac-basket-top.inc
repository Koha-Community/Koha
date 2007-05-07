<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>Кошик електронного каталогу</title>
	<!-- TMPL_IF NAME="TemplateEncoding" --><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><!-- TMPL_ELSE --><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><!-- /TMPL_IF -->
	<!-- TMPL_IF name="opacstylesheet" -->
		<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="opacstylesheet"-->" />
	<!-- TMPL_ELSE -->
		<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang"-->/includes/opac.css" />
	<!-- /TMPL_IF -->
	<script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/includes/basket.js"></script>
	<script language="JavaScript" type="text/javascript">
		function _(s) { return s } // dummy function for gettext
		//
	</script>
	<SCRIPT language='javascript'>
		var MSG_NO_RECORD_SELECTED = _("Не вибрано жодного бібліотечного запису");
		var MSG_NO_RECORD_ADDED = _("Не додано бібліотечного запису");
		var MSG_CONFIRM_DEL_BASKET = _("Ви хочете спорожнити кошик ?");
		var MSG_CONFIRM_DEL_RECORDS = _("Ви хочете видалити відібрані бібліотечні записи ?");
	</SCRIPT>
</head>
