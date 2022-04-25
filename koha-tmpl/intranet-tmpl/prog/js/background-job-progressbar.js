var backgroundJobProgressTimer = 0;
var jobID = '';
var savedForm;
var inBackgroundJobProgressTimer = false;
function updateJobProgress() {
    if (inBackgroundJobProgressTimer) {
        return;
    }
    inBackgroundJobProgressTimer = true;
    $.getJSON("/cgi-bin/koha/tools/background-job-progress.pl?jobID=" + jobID, function(json) {
        var percentage = json.job_status == 'completed' ? 100 :
                            json.job_size > 0              ? Math.floor(100 * json.progress / json.job_size) :
                            100;
        var bgproperty = (parseInt(percentage*2)-300)+"px 0px";
        $("#jobprogress").css("background-position",bgproperty);
        $("#jobprogresspercent").text(percentage);

        if (percentage == 100) {
            clearInterval(backgroundJobProgressTimer); // just in case form submission fails
            completeJob();
        }
        inBackgroundJobProgressTimer = false;
    });
}

function completeJob() {
    savedForm.completedJobID.value = jobID;
    savedForm.submit();
}

// submit a background job with data
// supplied from form f and activate
// progress indicator
function submitBackgroundJob(f) {
    // check for background field
    if (f.runinbackground) {
        // set value of this hidden field for
        // use by CGI script
        savedForm = f;
        f.mainformsubmit.disabled = true;
        f.runinbackground.value = 'true';

        // gather up form submission
        var inputs = [];
        $(':input:enabled', f).each(function() {
            if (this.type == 'radio' || this.type == 'checkbox') {
                if (this.checked) {
                    inputs.push(this.name + '=' + encodeURIComponent(this.value));
                }
            } else if (this.type == 'button') {
                ; // do nothing
            } else {
                inputs.push(this.name + '=' + encodeURIComponent(this.value));
            }

        });

        // and submit the request
        $("#jobpanel").show();
        $("#jobstatus").show();
        $.ajax({
            data: inputs.join('&'),
            url: f.action,
            dataType: 'json',
            type: 'post',
            success: function(json) {
                jobID = json.jobID;
                inBackgroundJobProgressTimer = false;
                backgroundJobProgressTimer = setInterval("updateJobProgress()", 500);
            },
            error: function(xml, textStatus) {
                humanMsg.displayMsg( '<p>' + __('Import of record(s) failed: ') + textStatus + '</p></br>'+xml.responseText, { className: 'humanError' } );
            }

        });

    } else {
        // background job support not enabled,
        // so just do a normal form submission
        f.submit();
    }

    return false;
}
