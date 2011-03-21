var tmpl_header = AJS.join('', [
    '<div id="top"> <img src="static_files/logo.gif" alt="" /> <br />',
    '<span style="font-weight: bold; color: #333">A pop-up window that doesn\'t suck.</span>',
    '</div>'
]);

function insertHeader() {
    AJS.DI(tmpl_header);
}

var LINKS = {
    'installation': 'installation.html',
    'examples': 'examples.html',
    'nrm_usage': 'normal_usage.html',
    'adv_usage': 'advance_usage.html',
    'cmpr': 'compressing_greybox.html',
    'about': 'about.html'
}

function insertMenu(current_page) {
    var menu = AJS.UL({id: 'menu'});
    var create_item = function(cls, name) {
        var item = AJS.LI({'class': cls});
        AJS.ACN(item, AJS.A({href: LINKS[cls]}, name));
        return item;
    }
    var items = [
        create_item('installation', 'Installation'),
        create_item('examples', 'Examples'),
        create_item('nrm_usage', 'Normal usage'),
        create_item('adv_usage', 'Advance usage'),
        create_item('cmpr', 'Compressing GreyBox'),
        create_item('about', 'About')
    ];

    AJS.map(items, function(item) {
        if(item.className == current_page) {
            AJS.addClass(AJS.$bytc('a', null, item)[0], 'current');
        }
        AJS.ACN(menu, item);
    });
    AJS.DI(menu);
}

function insertCode() {
    var code = AJS.join('\n', arguments);
    var result = '<pre><code>';
    code = code.replace(/</g, '&lt;').replace(/>/g, '&gt;');
    result += code;
    result += '</code></pre>';
    document.write(result);
}
