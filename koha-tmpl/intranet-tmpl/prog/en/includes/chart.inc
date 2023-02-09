<div class="modal" id="chartModal" tabindex="-1" role="dialog" aria-labelledby="chartModalLabel">
    <div class="modal-dialog modal-wide" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="closebtn" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="chartModalLabel">Chart settings</h4>
            </div>
            <div class="modal-body" id="makechart">
                [% supposed_x = header_row.shift.cell %]
                <fieldset class="rows">
                    <ol>
                        <li>
                            <label for="chart-type">Chart type: </label>
                            <select name="chart-type" id="chart-type">
                                <option value="pie">Pie</option>
                                <option value="bar">Bar</option>
                                <option value="line">Line</option>
                            </select>
                        </li>

                        <li id="chart-column-horizontal">
                            <label for="horizontal">Horizontal bar:</label>
                            <input id="horizontal" name="column-horizontal" type="checkbox" />
                        </li>

                        <li>
                            <label for="x_element">x column:</label>
                            <select id="x_element" name="x">
                                <option value="[% supposed_x | html %]" selected>[% supposed_x | html %]</option>
                                [% FOREACH header IN header_row %]
                                    <option value="[% header.cell | html %]">[% header.cell | html %]</option>
                                [% END %]
                            </select>
                        </li>

                        [% IF allresults.size %]
                            <li>
                                <label for="include-all">Include all rows (ignore pagination):</label>
                                <input id="include-all" name="chart-include-all" type="checkbox" checked="checked"/>
                            </li>
                        [% ELSE %]
                            <li>
                                <p>This chart will use only visible rows, click 'Fetch all data' to chart the full report</p>
                            </li>
                        [% END %]

                        <li>
                            <label for="exclude-last">Exclude last line (Rollup): </label>
                            <input id="exclude-last" name="chart-exclude-last" type="checkbox" />
                        </li>
                        [% column = 1 %]
                        <li class="column_config_row">
                            [% FOREACH header IN header_row %]
                                <fieldset class="chart-column-conf" id="column_[% column | html %]">
                                    <legend>
                                        Column [% column | html %]
                                        <a class="chart-column-delete" href="#" data-column="[% column | html %]">
                                            <i class="fa fa-times error"></i>
                                        </a>
                                    </legend>
                                    <div>
                                        <label for="y_[% column | html %]" >y:</label>
                                        <select id="y_[% column | html %]" name="y">
                                            <option value="[% supposed_x | html %]" selected>[% supposed_x | html %]</option>
                                            [% FOREACH h IN header_row %]
                                                [% IF header.cell == h.cell %]
                                                    <option value="[% h.cell | html %]" selected>[% h.cell | html %]</option>
                                                [% ELSE %]
                                                    <option value="[% h.cell | html %]">[% h.cell | html %]</option>
                                                [% END %]
                                        [% END %]
                                        </select>
                                    </div>

                                    <div class="chart-column-group">
                                        [% i = 1 %]
                                        <label for="group_[% column | html %]">Group:</label>
                                        <select id="group_[% column | html %]" name="group">
                                            [% FOREACH h IN header_row %]
                                                [% IF i == column %]
                                                    <option value="[% i | html %]" selected>[% i | html %]</option>
                                                [% ELSE %]
                                                    <option value="[% i | html %]">[% i | html %]</option>
                                                [% END %]
                                                [% i = i + 1 %]
                                            [% END %]
                                        </select>
                                    </div>

                                    <div class="chart-column-line">
                                        <label for="line_[% column | html %]">Line:</label>
                                        <input class="column-line" id="line_[% column | html %]" name="[% header.cell | html %]" type="checkbox" />
                                    </div>
                                </fieldset>
                                [% column = column + 1 %]
                            [% END %]
                        </li>
                    </ol>
                </fieldset>

                [% item = { cell = supposed_x } %]
                [% header_row.unshift(item) | html %]
            </div>
            <div class="modal-footer">
                <button id="draw-chart" class="btn btn-default">Draw</button>
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
