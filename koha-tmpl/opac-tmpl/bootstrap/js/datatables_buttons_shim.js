window.ButtonsShim = {};

ButtonsShim.export_format_spreadsheet = {
    body: function (data, row, column, node) {
        const newnode = node.cloneNode(true);
        const no_export_nodes = newnode.querySelectorAll(".no-export");
        no_export_nodes.forEach(child => {
            child.parentNode.removeChild(child);
        });
        //Note: innerHTML is the same thing as the data variable,
        //minus the ".no-export" nodes that we've removed
        //Note: See dataTables.buttons.js for original function usage
        const str = ButtonsShim.stripData(newnode.innerHTML, {
            decodeEntities: false,
            stripHtml: true,
            stripNewlines: true,
            trim: true,
            escapeExcelFormula: true
        });
        return str;
    },
};

ButtonsShim._stripHtml = function (input) {
    var _max_str_len = Math.pow(2, 28);
    var _re_html = /<([^>]*>)/g;
    if (! input || typeof input !== 'string') {
        return input;
    }
    // Irrelevant check to workaround CodeQL's false positive on the regex
    if (input.length > _max_str_len) {
        throw new Error('Exceeded max str len');
    }
    var previous;
    input = input.replace(_re_html, ''); // Complete tags
    // Safety for incomplete script tag - use do / while to ensure that
    // we get all instances
    do {
        previous = input;
        input = input.replace(/<script/i, '');
    } while (input !== previous);
    return previous;
};

ButtonsShim.stripHtml = function (mixed) {
    var type = typeof mixed;

    if (type === 'function') {
        ButtonsShim._stripHtml = mixed;
        return;
    }
    else if (type === 'string') {
        return ButtonsShim._stripHtml(mixed);
    }
    return mixed;
};
ButtonsShim.stripHtmlScript = function (input) {
    var previous;
    do {
        previous = input;
        input = input.replace(/<script\b[^<]*(?:(?!<\/script[^>]*>)<[^<]*)*<\/script[^>]*>/gi, '');
    } while (input !== previous);
    return input;
};
ButtonsShim.stripHtmlComments = function (input) {
    var previous;
    do {
        previous = input;
        input = input.replace(/(<!--.*?--!?>)|(<!--[\S\s]+?--!?>)|(<!--[\S\s]*?$)/g, '');
    } while (input !== previous);
    return input;
};
ButtonsShim.stripData = function (str, config) {
    // If the input is an HTML element, we can use the HTML from it (HTML might be stripped below).
    if (str !== null && typeof str === 'object' && str.nodeName && str.nodeType) {
        str = str.innerHTML;
    }

    if (typeof str !== 'string') {
        return str;
    }

    // Always remove script tags
    //str = Buttons.stripHtmlScript(str);
    str = ButtonsShim.stripHtmlScript(str);

    // Always remove comments
    //str = Buttons.stripHtmlComments(str);
    str = ButtonsShim.stripHtmlComments(str);

    if (!config || config.stripHtml) {
        //str = DataTable.util.stripHtml(str);
        str = ButtonsShim.stripHtml(str);
    }

    if (!config || config.trim) {
        str = str.trim();
    }

    if (!config || config.stripNewlines) {
        str = str.replace(/\n/g, ' ');
    }

    // Prevent Excel from running a formula
    if (!config || config.escapeExcelFormula) {
        if (str.match(/^[=@\t\r]/)) {
            str = "'" + str;
        }
    }

    return str;
};
