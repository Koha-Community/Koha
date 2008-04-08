<script type="text/javascript">//<![CDATA[
	$(document).ready(function() {
		var path = location.pathname.substring(1);
		$('#navmenulist a[@href$="/' + path + '"]').css('font-weight','bold');
	});
//]]>
</script>
<div id="navmenu"><ul id="navmenulist">
	<li><a href="/cgi-bin/koha/tools/tools-home.pl">Tools Home</a></li>
	<li><a href="/cgi-bin/koha/tools/koha-news.pl">News</a></li>
	<li><a href="/cgi-bin/koha/labels/label-home.pl">Labels (spine and barcode)</a></li>
	<li><a href="/cgi-bin/koha/tools/holidays.pl">Calendar</a></li>
	<li><a href="/cgi-bin/koha/tools/letter.pl">Notices</a></li>
	<li><a href="/cgi-bin/koha/tools/overduerules.pl">Notice/status triggers</a></li>
	<li><a href="/cgi-bin/koha/reviews/reviewswaiting.pl">Moderate OPAC comments</a></li>
	<li><a href="/cgi-bin/koha/tools/viewlog.pl">Log viewer</a></li>
	<li><a href="/cgi-bin/koha/tools/inventory.pl">Inventory/stocktaking</a></li>
	<li><a href="/cgi-bin/koha/tools/stage-marc-import.pl">MARC Import (staging)</a></li>
	<li><a href="/cgi-bin/koha/tools/manage-marc-import.pl">MARC Import (managing batches)</a></li>
	<li><a href="/cgi-bin/koha/tools/export.pl">Export bibs/holdings</a></li>
	<li><a href="/cgi-bin/koha/tools/import_borrowers.pl">Import patrons</a></li>
	<li><a href="/cgi-bin/koha/tools/cleanborrowers.pl">Patrons (anonomize, bulk-delete)</a></li>
	<li><a href="/cgi-bin/koha/tools/picture-upload.pl">Upload Patron Images</a></li>
	<li><a href="/cgi-bin/koha/tools/scheduler.pl">Task Scheduler</a></li>
</ul></div>
