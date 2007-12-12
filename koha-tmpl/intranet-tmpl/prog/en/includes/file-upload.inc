<!-- AJAX file upload stuff -->
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/plugins/ajaxfileupload.js"></script>
<script type="text/javascript">
    //<![CDATA
    function updateProgress() {
        $.getJSON("/cgi-bin/koha/tools/upload-file-progress.pl", function(json) {
            $("#fileuploadprogress").text(json.progress + '%');
            if (json.progress < 100) {
                setTimeout("updateProgress()",200);
            }
        });
    }
    function ajaxFileUpload()
    {

        $("#fileuploadstatus").show();
        setTimeout("updateProgress()",2000);
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
                    }
                },
                error: function (data, status, e) {
                    alert(e);
                }
            }
        )
        updateProgress();
        return false;

    }
    //]]>
</script>
