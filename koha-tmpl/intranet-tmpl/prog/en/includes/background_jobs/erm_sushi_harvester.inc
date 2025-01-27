[% USE Koha %]
[% USE raw %]

[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        <div class="alert alert-info">
            [% IF job.status == 'finished' %]
                <table id="finishedtable">
                    <tr>
                        <td>Usage data provider</td>
                        <td><a href="/cgi-bin/koha/erm/eusage/usage_data_providers/[% report.ud_provider_id | uri %]" title="Visit usage data provider">[% report.ud_provider_name | html %]</a></td>
                    </tr>
                    <tr>
                        <td>Report type</td>
                        <td>[% report.report_type | html %]</td>
                    </tr>
                    <tr>
                        <td>Report rows processed</td>
                        <td>[% job.progress | html %]</td>
                    </tr>
                    <tr>
                        [% IF report.report_type.match( '^PR' ) %]
                            <td>Platforms added</td>
                        [% ELSIF report.report_type.match( '^DR' ) %]
                            <td>Databases added</td>
                        [% ELSIF report.report_type.match( '^IR' ) %]
                            <td>Items added</td>
                        [% ELSIF report.report_type.match( '^TR' ) %]
                            <td>Titles added</td>
                        [% END %]
                        <td>[% report.us_report_info.added_usage_objects | html %]</td>
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
            [% ELSIF job.status == 'failed' %]
                <table id="finishedtable">
                    <tr>
                        <td>Usage data provider</td>
                        <td><a id="failed_provider_name" href="/cgi-bin/koha/erm/eusage/usage_data_providers/[% report.ud_provider_id | uri %]" title="Visit usage data provider"></a></td>
                    </tr>
                    <tr>
                        <td>Report type</td>
                        <td id="failed_report_type"></td>
                    </tr>
                </table>
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
            [% CASE 'object_already_exists' %]
                <span><strong>[% m.title | html %]</strong> already exists in this data provider and was not created. New usage statistics were verified anyway</span>
            [% CASE 'object_added' %]
                <span><strong>[% m.title | html %]</strong> successfully added</span>
            [% CASE 'object_could_not_be_added' %]
                <span><strong>[% m.title | html %]</strong> could not be processed - please check the logs</span>
            [% CASE 'payload_too_large' %]
                <span>COUNTER report file size exceeds limit defined by the database. Limit is [% m.message | html %] MB.</span><br />
                <span>Please increase this limit or harvest a shorter period.</span>
            [% CASE 'no_items' %]
                <span>SUSHI response returned no items.</span><br />
                <span>Please try a different harvest period.</span>
            [% CASE %]
                <span>SUSHI returned: [% m.message | html %] [% m.code | html %]</span>
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
            let job_id = [% job.id | $raw %];
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

            let job_data = [% job.data | $raw %];
            let report_type = job_data.report_type;
            let ud_provider_name = job_data.ud_provider_name;
            $('#failed_report_type').text(report_type);
            $('#failed_provider_name').text(ud_provider_name);
        });
    </script>
[% END %]
