<!-- AJAX file upload stuff -->
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/plugins/ajaxfileupload.js"></script>
<script type="text/javascript">
    //<![CDATA[
    var fileUploadProgressTimer = 0;
    var inFileUploadProgressTimer = false;
    var fileUploadProgressTimerCanceled = false;
    function updateProgress() {
        if (inFileUploadProgressTimer) {
            // since $.getJSON is asynchronous, wait
            // until the last one is finished
            return;
        }
        inFileUploadProgressTimer = true;
        $.getJSON("/cgi-bin/koha/tools/upload-file-progress.pl", function(json) {
            if (!fileUploadProgressTimerCanceled) {
				var bgproperty = (parseInt(json.progress)-300)+"px 0px";
                $("#fileuploadprogress").css("background-position",bgproperty);
				$("#fileuploadpercent").text(json.progress);
            }
            inFileUploadProgressTimer = false;
        });
    }
    function ajaxFileUpload()
    {
        fileUploadProgressTimerCanceled = false;
		$("#uploadpanel").show();
        $("#fileuploadstatus").show();
        fileUploadProgressTimer = setInterval("updateProgress()",500);
        $.ajaxFileUpload (
            {
                url:'/cgi-bin/koha/tools/upload-file.pl',
                secureuri:false,
                global:false,
                fileElementId:'fileToUpload',
                dataType: 'json',
                success: function (data, status) {
                    if (data.status == 'denied') {
                        $("#fileuploadstatus").hide();
                        $("#fileuploadfailed").show();
                        $("#fileuploadfailed").text("Upload failed -- no permission to upload files");
                    } else if (data.status == 'failed') {
                        $("#fileuploadstatus").hide();
                        $("#fileuploadfailed").show();
                        $("#fileuploadfailed").text("Upload failed -- unable to store file on server");
                    } else if (data.status == 'maintenance') {
                        $("#fileuploadstatus").hide();
                        $("#fileuploadfailed").show();
                        $("#fileuploadfailed").text("Upload failed -- database in maintenance state");
                    } else {
                         $("#uploadedfileid").val(data.fileid);
                         $("#fileuploadprogress").css("background-position","0px 0px");
						 $("#processfile").show();
                        $("#fileuploadpercent").text("100");
                    }
                    fileUploadProgressTimerCanceled = true;
                    clearInterval(fileUploadProgressTimer);
                },
                error: function (data, status, e) {
                    fileUploadProgressTimerCanceled = true;
                    alert(e);
                    clearInterval(fileUploadProgressTimer);
                }
            }
        )
        return false;

    }
    //]]>
</script>
