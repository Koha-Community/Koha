<div id="toolbar">
				<a id="addbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl">New</a>
			<input type="submit" id="editbutton" name="editbutton_button" value="Edit">
            <select id="editbuttonselect" name="editbuttonselect">
                <option value="0">Bibliographic Record</option>
                <option value="1">Items</option>
                <option value="2">As New Record (Duplicate)</option>                
            </select>
	                <a id="deletebiblio" href="javascript:confirm_deletion(<!-- TMPL_VAR NAME="count" -->)">Delete</a>

	                <a id="addtoshelf" href="#" onclick="window.open('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->','Add_to_virtualshelf','width=500,height=400,toolbar=false,scrollbars=yes'); return false;">Add to shelf</a>
	                <a id="printbiblio" href="/cgi-bin/koha/catalogue/detailprint.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Print</a>
	                
	                <!-- TMPL_IF NAME="norequests" --><!-- TMPL_ELSE --><a id="placehold" href="/cgi-bin/koha/reserve/request.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Place Hold</a><!-- /TMPL_IF -->
	

    <br clear="all" /></div>
