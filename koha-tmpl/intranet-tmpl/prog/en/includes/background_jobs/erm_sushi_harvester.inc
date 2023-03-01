[% USE Koha %]

[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        <div class="dialog message">
            [% IF job.status == 'finished' %]
                <table id="finishedtable">
                    <tr>
                        <td>Usage data provider</td>
                        <td><a href="/cgi-bin/koha/erm/eusage/usage_data_providers/[% report.ud_provider_id %]" title="Visit usage data provider">[% report.ud_provider_name | html %]</a></td>
                    </tr>
                    <tr>
                        <td>Report type</td>
                        <td>[% report.report_type | html %]</td>
                    </tr>
                    <tr>
                        <td>Report rows processed</td>
                        <td>[% job.progress %]</td>
                    </tr>
                    <tr>
                    [% IF report.report_type.match( '^PR' ) %]
                        <td>Platforms processed</td>
                    [% ELSIF report.report_type.match( '^DR' ) %]
                        <td>Databases processed</td>
                    [% ELSIF report.report_type.match( '^IR' ) %]
                        <td>Items processed</td>
                    [% ELSIF report.report_type.match( '^TR' ) %]
                        <td>Titles processed</td>
                    [% END %]
                        <td>[% report.total_records | html %]</td>
                    </tr>
                    <tr>
                        <td>Monthly usages skipped</td>
                        <td>[% report.us_report_info.skipped_mus | html %]</td>
                    </tr>
                    <tr>
                        <td>Monthly usages added</td>
                        <td>[% report.us_report_info.added_mus | html %]</td>
                    </tr>
                    <tr>
                        <td>Yearly usages skipped</td>
                        <td>[% report.us_report_info.skipped_yus | html %]</td>
                    </tr>
                    <tr>
                        <td>Yearly usages added</td>
                        <td>[% report.us_report_info.added_yus | html %]</td>
                    </tr>
                </table>
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
        <div class="dialog message">
            [% IF m.type == 'success' %]
                <i class="fa fa-check success"></i>
            [% ELSIF m.type == 'warning' %]
                <i class="fa fa-warning warn"></i>
            [% ELSIF m.type == 'error' %]
                <i class="fa fa-exclamation error"></i>
            [% END %]
            [% SWITCH m.code %]
            [% CASE 'object_already_exists' %]
                <span><strong>[% m.title %]</strong> already exists in this data provider and was not created. New usage statistics were verified anyway</span>
            [% CASE 'object_added' %]
                <span><strong>[% m.title %]</strong> successfully added</span>
            [% END %]
        </div>
    [% END %]
[% END %]
    [% Asset.js("js/job_progress.js") | $raw %]

[% BLOCK js %]
    [% INCLUDE 'str/job_progress.inc' job_id=job.id %]
    [% INCLUDE 'str/erm_sushi_harvester.inc' %]
<script>
        $(document).ready(function(){
            let job_id = [% job.id | html %];
            updateProgress(job_id, {
                progress_callback : function(){
                    $.getJSON('/api/v1/jobs/'+job_id, function(job){
                        if(job.progress == 0){
                            $('#jobactionlabel').text(REQUESTING_SUSHI);
                        }else if(job.progress >= 1){
                            $('#jobactionlabel').text(CREATING_COUNTER);
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
