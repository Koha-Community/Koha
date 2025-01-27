function updateProgress(job_id, callbacks) {
    $.getJSON("/api/v1/jobs/" + job_id, function (job) {
        let recheck = true;

        if (job.status == "new") {
            $("#progress-" + job_id).attr("aria-valuenow", 0);
            $("#progress-bar-" + job_id).width("100%");
            $("#progress-bar-" + job_id).text(
                "0" + JOB_PROGRESS_PERCENT + " " + JOB_PROGRESS_NOT_STARTED
            );
        } else if (job.status == "started") {
            const progress = job["progress"];
            const size = job["size"];
            const percent = progress > 0 ? (progress / size) * 100 : 0;
            $("#progress-" + job_id).attr("aria-valuenow", percent);
            $("#progress-bar-" + job_id).width(Math.floor(percent) + "%");
            $("#progress-bar-" + job_id).text(
                percent.toFixed(2) +
                    JOB_PROGRESS_PERCENT +
                    " " +
                    JOB_PROGRESS_STARTED
            );
            typeof callbacks.progress_callback === "function" &&
                callbacks.progress_callback();
        } else if (job.status == "finished") {
            $("#progress-bar-" + job_id).addClass("bg-success");
            $("#progress-" + job_id).attr("aria-valuenow", 100);
            $("#progress-bar-" + job_id).css("width", "100%");
            $("#progress-bar-" + job_id).text(
                "100" + JOB_PROGRESS_PERCENT + " " + JOB_PROGRESS_FINISHED
            );
            recheck = false;
            typeof callbacks.finish_callback === "function" &&
                callbacks.finish_callback();
        } else if (job.status == "failed") {
            $("#progress-bar-" + job_id).addClass("bg-danger");
            $("#progress" + job_id).attr("aria-valuenow", 0);
            $("#progress-bar-" + job_id).css("width", "100%");
            $("#progress-bar-" + job_id).text(
                "0" + JOB_PROGRESS_PERCENT + " " + JOB_PROGRESS_FAILED
            );
            recheck = false;
        }

        if (recheck) {
            setTimeout(function () {
                updateProgress(job_id, callbacks);
            }, 1 * 1000);
        }
    });
}
