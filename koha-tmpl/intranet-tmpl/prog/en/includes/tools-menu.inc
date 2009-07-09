<script type="text/javascript">//<![CDATA[
	$(document).ready(function() {
		var path = location.pathname.substring(1);
		$('#navmenulist a[href$="/' + path + '"]').css('font-weight','bold');
	});
//]]>
</script>
<div id="navmenu"><ul id="navmenulist">
	<li><a href="/cgi-bin/koha/tools/tools-home.pl">Tools Home</a></li>
    <!-- TMPL_IF NAME="CAN_user_tools_edit_news" -->
	<li><a href="/cgi-bin/koha/tools/koha-news.pl">News</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools_label_creator" -->
	<li><a href="/cgi-bin/koha/labels/label-home.pl">Labels (spine and barcode)</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools_edit_calendar" -->
	<li><a href="/cgi-bin/koha/tools/holidays.pl">Calendar</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools_edit_notices" -->
	<li><a href="/cgi-bin/koha/tools/letter.pl">Notices</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools_edit_notice_status_triggers" -->
	<li><a href="/cgi-bin/koha/tools/overduerules.pl">Notice/status triggers</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools_moderate_comments" -->
	<li><a href="/cgi-bin/koha/reviews/reviewswaiting.pl">Moderate OPAC comments</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools_moderate_comments" --><!-- FIXME: Update here when Tag specific permission is created. --><li><a href="/cgi-bin/koha/tags/review.pl">Moderate patron tags</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools_view_system_logs" -->
	<li><a href="/cgi-bin/koha/tools/viewlog.pl">Log viewer</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools_inventory" -->
	<li><a href="/cgi-bin/koha/tools/inventory.pl">Inventory/stocktaking</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools_stage_marc_import" -->
	<li><a href="/cgi-bin/koha/tools/stage-marc-import.pl">MARC Import (staging)</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools_manage_staged_marc" -->
	<li><a href="/cgi-bin/koha/tools/manage-marc-import.pl">MARC Import (managing batches)</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools_export_catalog" -->
	<li><a href="/cgi-bin/koha/tools/export.pl">Export bibs/holdings</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools_import_patrons" -->
	<li><a href="/cgi-bin/koha/tools/import_borrowers.pl">Import patrons</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools_delete_anonymize_patrons" -->
	<li><a href="/cgi-bin/koha/tools/cleanborrowers.pl">Patrons (anonymize, bulk-delete)</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools_batch_upload_patron_images" -->
	<li><a href="/cgi-bin/koha/tools/picture-upload.pl">Upload Patron Images</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools_schedule_tasks" -->
	<li><a href="/cgi-bin/koha/tools/scheduler.pl">Task Scheduler</a></li>
    <!-- /TMPL_IF -->
</ul></div>
