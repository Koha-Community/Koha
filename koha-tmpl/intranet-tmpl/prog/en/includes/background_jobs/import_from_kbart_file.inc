[% USE Koha %]
[% USE raw %]

[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        <div class="alert alert-info">
            [% IF job.status == 'finished' %]
                <table id="finishedtable">
                    <tr>
                        <td>Filename</td>
                        <td>[% report.file_name | html %]</td>
                    </tr>
                    <tr>
                        <td>Total lines processed</td>
                        <td>[% report.total_rows | html %]</td>
                    </tr>
                    <tr>
                        <td>Titles imported</td>
                        <td>[% report.titles_imported | html %]</td>
                    </tr>
                    <tr>
                        <td>Duplicates found</td>
                        <td>[% report.duplicates_found | html %]</td>
                    </tr>
                    <tr>
                        <td>Failed imports</td>
                        <td>[% report.failed_imports | html %]</td>
                    </tr>
                </table>
                <a href="/cgi-bin/koha/erm/eholdings/local/packages/[% report.package_id | $raw %]">Package</a>
            [% ELSIF job.status == 'started' %]
                <p id="jobactionlabel"></p>
            [% END %]
            [% IF job.status != 'finished' %]
                [% INCLUDE "job_progress.inc" job_id=job.id %]
            [% END %]
            [% IF job.status == 'cancelled' %]
                <p>The job has been cancelled before it finished.</p>
            [% END %]
        </div>
    [% END %]
[% END %]

[% Asset.js("js/job_progress.js") | $raw %]

[% BLOCK detail %]
    [% FOR m IN job.messages %]
        <div class="alert alert-info">
            [% IF m.type == 'success' %]
                <i class="fa fa-check success"></i>
            [% ELSIF m.type == 'warning' %]
                <i class="fa fa-warning warn"></i>
            [% ELSIF m.type == 'error' %]
                <i class="fa fa-exclamation error"></i>
            [% END %]
            [% SWITCH m.code %]
            [% CASE 'title_already_exists' %]
                <span><strong>[% m.title | html %]</strong> already exists and was not created.</span>
            [% CASE 'no_title_found' %]
                <span><strong>Title [% m.title_id | html %]</strong> did not have a publication title and was not imported.</span>
            [% CASE 'title_failed' %]
                <span><strong>Title [% m.title_id | html %]</strong> failed to import with the following error: [% m.error_message | html %]</span>
            [% CASE 'no_rows' %]
                <span>No valid rows were found in this file. Please check the file formatting.</span>
            [% END %]
        </div>
    [% END %]
[% END %]

[% BLOCK js %]
    [% INCLUDE 'str/job_progress.inc' job_id=job.id %]
    [% INCLUDE 'str/import_from_kbart_file.inc' %]
    <script>
        $(document).ready(function(){
            let job_id = [% job.id | html %];
            updateProgress(job_id, {
                progress_callback : function(){
                    $.getJSON('/api/v1/jobs/'+job_id, function(job){
                        if(job.progress == 0){
                            $('#jobactionlabel').text(READING_FILE);
                        }else if(job.progress >= 1){
                            $('#jobactionlabel').text(PROCESSING_FILE);
                        }
                    });
                },
                finish_callback : function(){
                    $.getJSON('/api/v1/jobs/'+job_id, function(job){
                        if(!$('#finishedtable').length){
                            window.location.reload();
                        }
                    });
                }
            });
        });
    </script>
[% END %]
