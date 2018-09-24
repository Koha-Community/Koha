function create_chart(headers, results, x_element, y_elements, y_groups, options) {

    var type = options.type;
    var horizontal = options.horizontal;
    var lines = options.lines;
    var data;
    var axis;

    if (type != 'pie') {
        var columns = build_columns(headers, results, x_element, y_elements);
        var groups = build_group(y_elements, y_groups);
        var x_values = build_xvalues(headers, results, x_element);

        axis = {
            x: {
                type: 'category',
                categories: x_values
            }
        };

        data = {
            columns: columns,
            groups: groups,
            type: type,
        };

    }
    else {
        var columns = build_pie_columns(headers, results, x_element);
        data = {
            columns: columns,
            type: type,
        };

    }

    if (type == 'bar') {
        var types = {};
        $.each(lines, function(index, value) {
            types[value] = 'line';
        });
        data.types = types;

        if (horizontal) {
            axis.rotated = true;
        }
    }

    var chart = c3.generate({
        bindto: '#chart',
        data: data,
        axis: axis,
    });

    return chart;
}

function build_pie_columns(headers, results, x_element) {
    var columns = [];
    var x_index;

    //Get x_element index.
    $.each(headers, function(index, value) {
        if (value.cell == x_element) {
            x_index = index;
        }
    });

    $.each(results, function(index, value) {
        var cells = value.cells;
        $.each( cells, function(i, value) {
            if (i == x_index) {
                columns[index] = [value.cell];
            }
        });
        $.each( cells, function(i, value) {
            if (i != x_index) {
                columns[index].push(value.cell);
            }
        });
    });

    return columns;
}

function build_xvalues(headers, results, x_element) {
    var h_index;
    x_values = [];

    //Get x_element index.
    $.each(headers, function(index, value) {
        if (value.cell == x_element) {
            h_index = index;
        }
    });

    $.each( results, function (i, value) {
        var cells = value.cells;
        $.each( cells, function(index, value) {
            if (index == h_index) {
                x_values.push(value.cell);
            }
        });
    });

    return x_values;

}

function build_group(y_elements, y_groups) {
    var groups_hash = {};
    var groups = [];

    $.each(y_groups, function(index, value) {
        var related_y = y_elements.shift();
        if (!$.isArray(groups_hash[value])) {
            groups_hash[value] = [];
        }
        groups_hash[value].push(related_y);
    });

    $.each(groups_hash, function(key, value) {
        if (value.length !== 0) {
            groups.push(value);
        }
    });

    return groups;
}

function build_columns(headers, results, x_element, y_elements) {
    var x_index;
    var header_index = [];
    var y_values = {};

    // Keep order of headers using array index.
    $.each( headers, function(index, value) {
        if (value.cell == x_element) {
            x_index = index;
        }
        header_index.push(value.cell)
    });

    $.each( y_elements, function(index, element) {
        y_values[element] = [element];
    });

    $.each( results, function (i, value) {
        var cells = value.cells;
        $.each( cells, function(index, value) {
            if (index != x_index) {
                y_values[header_index[index]].push(value.cell);
            }
        });
    });

    var columns = [];
    $.each( y_values, function(key, value) {
        columns.push(value);
    });

    return columns;
}
