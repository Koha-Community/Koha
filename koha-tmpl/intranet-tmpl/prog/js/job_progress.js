function updateProgress(job_id, callback) {
    $.getJSON('/api/v1/jobs/' + job_id, function(job){
        let recheck = true;

        if ( job.status == "new" ) {
            $('#job-percent-' + job_id).text(0);
            $('#job-status-' + job_id).text(JOB_PROGRESS_NOT_STARTED);
            $('#progress-bar-' + job_id).attr('aria-valuenow', 0).css("width", "100%");
        } else if ( job.status == "started" ) {
            const progress = job["progress"];
            const size = job["size"];
            const percent = progress > 0 ? ( progress / size ) * 100 : 0;
            $('#job-percent-' + job_id).text(percent.toFixed(2));
            $('#job-status-' + job_id).text(JOB_PROGRESS_STARTED);
            $('#progress-bar-' + job_id).attr('aria-valuenow', percent);
            $('#progress-bar-' + job_id).width(Math.floor(percent) +"%");
        } else if ( job.status == "finished" ) {
            $('#job-percent-' + job_id).text(100);
            $('#job-status-' + job_id).text(JOB_PROGRESS_FINISHED);
            $('#progress-bar-' + job_id).addClass("progress-bar-success");
            $('#progress-bar-' + job_id).attr('aria-valuenow', 100).css("width", "100%");
            recheck = false;
            callback();
        } else if ( job.status == "failed" ) {
            $('#job-percent-' + job_id).text(0);
            $('#job-status-' + job_id).text(JOB_PROGRESS_FAILED);
            $('#progress-bar-' + job_id).addClass("progress-bar-danger");
            $('#progress-bar-' + job_id).attr('aria-valuenow', 0).css("width", "100%");
            recheck = false;
        }

        if ( recheck ) {
            setTimeout(function(){updateProgress(job_id, callback)}, 1 * 1000);
        }
    });
}
