<!-- AJAX file upload stuff -->
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/plugins/ajaxfileupload.js"></script>
<script type="text/javascript" src="/intranet-tmpl/prog/en/lib/jquery/plugins/ajaxfileupload.js"></script>
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
                    $("#uploadedfileid").val(data.fileid);
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
