<script language="JavaScript" type="text/javascript">
var TID; //the timeout identifier
var Mduration=500; // how long before closing the menu
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}
/*var ie = (document.all) ? 1:0;
var ns7 = (document.getElementById) ? 1:0;*/
		function MM_findObj(n, d) { //v4.0
			var p,i,x;
			if(!d) d=document;
			if((p=n.indexOf("?"))>0&&parent.frames.length) {
				d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);
			}
			if(!(x=d[n])&&d.all) x=d.all[n];
			for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
			for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
			if(!x && document.getElementById) x=document.getElementById(n);
			return x;
		}
		function SetOn(item) {
			for(i=1;i<=7;i++) {
				SetOff(i);
			}
			CancelTimeOut(TID);
			if (!(layer = MM_findObj('Subm' + item))) return;
			layer.style.visibility = 'visible';
		}
		function LaunchSetOff(item) {
			if (TID) {
				CancelTimeOut(TID);
			}
			TID=setTimeout('SetOff('+item+')',Mduration);
		}
		function CancelTimeOut(TID) {
			clearTimeout(TID);
		}
		function SetOff(item) {
			if (!(layer = MM_findObj('Subm' + item))) return;
			layer.style.visibility = 'hidden';
		}
</script>

<!-- MENUS -->
<!-- ACQUISITION -->
<div id="Subm1"> 
  <a href="/cgi-bin/koha/acqui/acqui-home.pl" class="submenu acquisition" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(1)">Main page</a>
  <a href="/cgi-bin/koha/acqui/lateorders.pl" class="submenu acquisition" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(1)">Late orders</a>
  <a href="/cgi-bin/koha/acqui/histsearch.pl" class="submenu acquisition" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(1)">History search</a>
</div>

<!-- CATALOGUE -->
<div id="Subm2"> 
	<a href="/cgi-bin/koha/loadmodules.pl?module=search&amp;marc=1&amp;type=intranet" class="submenu catalogue" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(2)">Search</a>
	<a href="/cgi-bin/koha/loadmodules.pl?module=addbiblio&amp;type=intranet" class="submenu catalogue" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(2)">Add biblio</a>
	<hr>
	<a class="submenu bull" href="/cgi-bin/koha/bull-home.pl" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(2)">Subscriptions</a>
	<a href="/cgi-bin/koha/bull/lateissues.pl" class="submenu bull" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(2)">Late issues</a>
	<hr />
	<a href="/cgi-bin/koha/bookshelves/shelves.pl" class="submenu catalogue" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(2)">Virtual shelves</a>
</div>
<!-- CIRC -->
<div id="Subm3"> 
	<a href="/cgi-bin/koha/circ/circulation.pl" class="submenu circulation" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(3)">Issues</a>
	<a href="/cgi-bin/koha/circ/returns.pl" class="submenu circulation" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(3)">Returns</a>
	<a href="/cgi-bin/koha/circ/branchtransfers.pl" class="submenu circulation" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(3)">Branch transfers</a>
	<hr />
	<a href="/cgi-bin/koha/circ/reserve.pl" class="submenu circulation" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(3)">Reserves pending</a>
</div>
<!-- MEMBERS -->
<div id="Subm4"> 
 	<a href="/cgi-bin/koha/members/members-home.pl" class="submenu members" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(4)">Search</a>
	<a href="/cgi-bin/koha/members/memberentry.pl?actionType=Add" class="submenu members" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(4)">Add member</a>
	<a href="/cgi-bin/koha/members/memberentry.pl?categorycode=I&amp;actionType=Add" class="submenu members" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(4)">Add organisation</a>
</div>
<!-- AUTHORITIES -->
<div id="Subm5"> 
	<a href="/cgi-bin/koha/authorities/authorities-home.pl" class="submenu authority" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(5)">Authorities</a>
</div>
<!-- REPORTS -->
<div id="Subm6"> 
	<a href="/cgi-bin/koha/reports/acquisitions_stats.pl" class="submenu reports" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(6)">Acquisitions</a>
	<a href="/cgi-bin/koha/reports/borrowers_stats.pl" class="submenu reports" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(6)">Borrowers</a>
	<a href="/cgi-bin/koha/reports/catalogue_stats.pl" class="submenu reports" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(6)">Catalogue</a>
	<a href="/cgi-bin/koha/reports/issues_stats.pl" class="submenu reports" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(6)">Circulation</a>
	<hr />
	<a href="/cgi-bin/koha/reports/bor_issues_top.pl" class="submenu reports" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(6)">Most issuing Borrowers</a>
	<a href="/cgi-bin/koha/reports/cat_issues_top.pl" class="submenu reports" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(6)">Most issued items</a>
	<hr />
	<a href="/cgi-bin/koha/reports/borrowers_out.pl" class="submenu reports" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(6)">Borrowers without issues</a>
	<a href="/cgi-bin/koha/reports/catalogue_out.pl" class="submenu reports" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(6)">Items not issued</a>
	<a href="/cgi-bin/koha/reports/inventory.pl" class="submenu reports" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(6)">Inventory/Stocktaking</a>
	<a href="/cgi-bin/koha/reports/manager.pl?report_name=itemtypes" class="submenu reports" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(6)">Catalogue by itemtype</a>
	<a href="/cgi-bin/koha/stats.pl?time=yesterday" class="submenu reports" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(6)">Till Reconciliation (yesterday)</a>
	<a href="/cgi-bin/koha/stats.pl?time=today" class="submenu reports" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(6)">Till Reconciliation (today)</a>
	<a href="/cgi-bin/koha/overdue.pl" class="submenu reports" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(6)">Overdue items</a>
	<a href="/cgi-bin/koha/reports/manager.pl?report_name=issues_by_borrower_category" class="submenu reports" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(6)">Issues by borrower category</a>
	<a href="/cgi-bin/koha/reports/issues_avg_stats.pl" class="submenu reports" onMouseOver="CancelTimeOut(TID)" onMouseOut="LaunchSetOff(6)">Average loan time</a>
</div>
<!-- PARAMETERS -->
<div id="Subm7"> 
	<TMPL_IF name="CAN_user_parameters">	
		<a class="submenu parameters" href="/cgi-bin/koha/admin/branches.pl" title="The different branches you manage with this Koha server." onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Library branches</a>
	</TMPL_IF>
	<TMPL_IF name="CAN_user_management">
		<a href="/cgi-bin/koha/admin/aqbookfund.pl" title="Book fund administration. Remember to edit your book funds before you start editing the budgets." class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Book funds</a>
		<a href="/cgi-bin/koha/admin/currency.pl" title="Define exchange rates"class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Currencies</a>
		<a href="/cgi-bin/koha/admin/itemtypes.pl" title="Define item types"class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Item types</a>
		<hr />
		<a href="/cgi-bin/koha/admin/categorie.pl" title="Define the categories of borrowers"class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Borrower categories</a>
		<a href="/cgi-bin/koha/admin/issuingrules.pl" title="Define issuing rules for branches / borrowers / item types (nb of issues, duration, cost...)"class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Issuing rules</a>
		<hr />
		<a href="/cgi-bin/koha/admin/authorised_values.pl" title="Define categories and authorised values for them. Authorised values are used in MARC form to limit and help editing MARC biblios" class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Authorised values</a>
	</TMPL_IF>
		
	<TMPL_IF name="CAN_user_parameters">
		<a href="/cgi-bin/koha/admin/authtypes.pl" title="Define categories and thesaurus/authority MARC structure" class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Thesaurus Structure</a>
		<a href="/cgi-bin/koha/admin/biblio_framework.pl" title="the frameworks defined for the MARC editor. Create frameworks, then define the MARC structure (fields &amp; subfields)" class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Biblio framework (MARC structure)</a>
		<a href="/cgi-bin/koha/admin/koha2marclinks.pl" title="Define links between the Koha standard DB and the MARC one. Note those links can be defined through MARC structure. This tool is just a shortcut to speed up linkage" class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Links Koha - MARC DB</a>
		<a href="/cgi-bin/koha/admin/checkmarc.pl" title="Checks the MARC structure. USE IT before working with real data. It will show mistakes that can BREAK Koha's database!" class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">MARC Check</a>
		<hr>
		<a href="/cgi-bin/koha/admin/printers.pl" title="Printers (UNIX paths)" class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Printers</a>
	</TMPL_IF>
	
	<TMPL_IF name="CAN_user_management">
		<a href="/cgi-bin/koha/admin/stopwords.pl" title="Words deleted during searches" class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Stop words</a>
	</TMPL_IF>
	
	<TMPL_IF name="CAN_user_parameters">
		<a href="/cgi-bin/koha/admin/z3950servers.pl" title="Servers to query for MARC data"class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Z39.50 Servers</a>
		<a href="/cgi-bin/koha/admin/systempreferences.pl" title="System preferences"class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">System preferences</a>
	</TMPL_IF>

<TMPL_IF name="CAN_user_tools">
	<hr>
		<a href="/cgi-bin/koha/export/marc.pl" title="Exporting in MARC format" class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">MARC biblio export</a>
		<a href="/cgi-bin/koha/import/breeding.pl" title="The reservoir is a table where imported MARC records are stored. A MARC record is stored in the reservoir as long as you have no item. When you type the ISBN or title of a biblio, it's searched for in the reservoir. If it is found, the biblio is added to Koha active table" class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Upload MARC records in reservoir</a>
		<a href="/cgi-bin/koha/barcodes/barcodes.pl" title="the barcode generator deals with generating barcodes for items you acquire" class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Generate barcodes</a>
		<a href="/cgi-bin/koha/admin/letter.pl" title="Letters to use in Koha" class="submenu parameters" onMouseOver="CancelTimeOut(TID)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Letters</a>
</TMPL_IF>

</div>
<!-- MENUS -->
<div id="menubar">
	<span class="koha"><a class="home" href="/cgi-bin/koha/mainpage.pl">Koha</a></span>
	<a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions" onMouseOver="SetOn(1)">Acquisitions</a>
	<a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=search&amp;type=intranet" onMouseOver="SetOn(2)">Catalogue</a>
	<a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl" onMouseOver="SetOn(3)">Circulation</a>
	<a class="members" href="/cgi-bin/koha/members/members-home.pl" onMouseOver="SetOn(4)">Members</a>
	<a class="authority" href="/cgi-bin/koha/authorities/authorities-home.pl" onMouseOver="SetOn(5)">Authorities</a>
	<a class="reports" href="/cgi-bin/koha/reports-home.pl" onMouseOver="SetOn(6)">Reports</a>
	<a class="parameters" href="/cgi-bin/koha/admin-home.pl" onMouseOver="SetOn(7)" onMouseOut="TID=setTimeout('SetOff(7)',Mduration)">Parameters</a>
	<a class="about" href="/cgi-bin/koha/about.pl">About</a>
	<a class="catalogue" href="/cgi-bin/koha/help.pl" onclick="Help(); return false;">Help</a>
</div>