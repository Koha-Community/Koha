<!doctype html public "-//w3c//dtd html 4.0 transitional//en">

<html>
<head>
<title>KOHA: INTRANET: Acquisitions</title>
</head>
<body text="black" bgcolor="white" link="#0000ff" vlink="#0000ff" "3366cc" Alink="#cc3300"
marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>

<style>
#menubar {
	border-top:1px solid #666;
}
.koha {
	font-weight: normal;
	text-decoration: none;
	cursor: hand;
	color:#777777;
	padding:4px;
	font-weight: bold;
	text-align:center;
	background-image:url("/images/background-mem.gif");
	}

a.home {
	font-weight: normal;
	text-decoration: none;
	cursor: hand;
	color:#777777;
	padding:4px;
	font-weight: bold;
	}
a.home:hover {
	background-color: #339933;
	color: #000000;
	text-decoration: none;
	font-weight: normal;
	font-weight: bold;
	}
a.catalogue {
	font-weight: normal;
	text-decoration: none;
	cursor: hand;
	color:#777777;
	padding:4px;
	font-weight: bold;
	margin:0;
	}
a.catalogue:hover {
	background-color: #ad11ad;
	color: #000000;
	text-decoration: none;
	font-weight: normal;
	font-weight: bold;
	margin:0;
	}
a.members {
	font-weight: normal;
	text-decoration: none;
	cursor: hand;
	color:#777777;
	padding:4px;
	font-weight: bold;
	}
a.members:hover {
	background-color: #86c268;
	color: #000000;
	text-decoration: none;
	font-weight: bold;
	}

a.acquisition {
	font-weight: normal;
	text-decoration: none;
	background-color: #ffdf61;
	cursor: hand;
	color:#000000;
	padding:4px;
	font-weight: bold;
	}
a.acquisition:hover {
	background-color: #ffdf61;
	color: #000000;
	text-decoration: normal;
	font-weight: bold;
	}
a.reports {
	font-weight: normal;
	text-decoration: none;
	cursor: hand;
	color:#777777;
	padding:4px;
	font-weight: bold;
	}
a.reports:hover {
	background-color: #6b7cbe;
	color: #000000;
	text-decoration: normal;
	font-weight: bold;
	}
a.circulation {
	font-weight: normal;
	text-decoration: none;
	cursor: hand;
	color:#777777;
	padding:4px;
	font-weight: bold;
	}
a.circulation:hover {
	background-color: #be6170;
	color: #000000;
	text-decoration: normal;
	font-weight: bold;
	}
a.parameters {
	font-weight: normal;
	text-decoration: none;
	cursor: hand;
	color:#777777;
	padding:4px;
	font-weight: bold;
	}
a.parameters:hover {
	background-color: #86c268;
	color: #000000;
	text-decoration: normal;
	font-weight: bold;
	}
</style>

<!------------------------MENUS-------------------------------->
<table cellpadding=0 cellspacing=0 width="100%" border=0>
<tr height="45">
	<td valign="bottom" align="left">
		<table bgcolor="dddddd" width="100%" cellpadding=0 cellspacing=0>
		<tr>
			<td>
			<div id="menubar">
			<table cellpadding=0 cellspacing=0  border=0 height=29 width=70%>
				<tr>
					<td class="koha"><b>KOHA</b></td>
					<td>
						<a class="home" href="/cgi-bin/koha/mainpage.pl">Home</a>
					</td>
					<td>
						<a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=search&type=intranet">Catalogue</a>
					</td>
					<td>
						<a class="members" href="/cgi-bin/koha/members-home.pl">Members</a>
					</td>
					<td>
						<a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Acquisition</a>
					</td>
					<td>
						<a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=cataloguing">Cataloguing</a>
					</td>
					<td>
						<a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl">Circulation</a>
					</td>
					<td>
						<a class="reports" href="/cgi-bin/koha/reports-home.pl">Reports</a>
					</td>
					<td>
						<a class="parameters" href="/cgi-bin/koha/admin-home.pl">Parameters</a>
					</td>
				</TR>
			</TABLE>
			</div>
		</td></tr></table>
	</TD>
</tr>
</table>
