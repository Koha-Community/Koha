<div id="makechart" style="display:none;">
    [% supposed_x = header_row.shift.cell %]

    <fieldset>
        <legend>Draw a chart</legend>
        <ol>
            <li>
                <label for="chart-type">Chart type</label>
                <select name="chart-type" id="chart-type">
                    <option value="pie">Pie</option>
                    <option value="bar">Bar</option>
                    <option value="line">Line</option>
                </select>

                <div id="chart-column-horizontal">
                    <label for="horizontal">Horizontal bar:</label>
                    <input id="horizontal" name="column-horizontal" type="checkbox">
                </div>
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

            <div>
                <label for="include-all">Include all rows (ignore pagination)</label>
                <input id="include-all" name="chart-include-all" type="checkbox">
            </div>


            <label for="exclude-last">Exclude last line (Rollup)</label>
            <input id="exclude-last" name="chart-exclude-last" type="checkbox">

            [% column = 1 %]
            <li>
                [% FOREACH header IN header_row %]
                    <fieldset class="chart-column-conf" id="column_[% column | html %]" style="display: inline !important;">
                        <legend>
                            Column [% column | html %]
                            <a class="chart-column-delete" href="#" data-column="[% column | html %]">
                                <img src="[% interface | html %]/[% theme | html %]/img/x.png" alt="Delete" />
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
                            <label for="line_[% column | html %]">line:</label>
                            <input class="column-line" id="column-line" name="[% header.cell | html %]" type="checkbox">
                        </div>
                    </fieldset>
                    [% column = column + 1 %]
                [% END %]
            </li>

            <li>
                <button id="draw-chart" class="btn btn-default">Draw</button>
            </li>
        </ol>
    </fieldset>
    [% item = { cell = supposed_x } %]
    [% header_row.unshift(item) | html %]
    <div id="chart"></div>
</div>
