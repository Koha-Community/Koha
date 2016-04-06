//package RadialMenu
if (typeof RadialMenu == "undefined") {
    this.RadialMenu = {}; //Set the global package
}

/**
 *  Deploys a nice radial menu replacing the given container.
 *
 *  USAGE:
 *  1. Include css styles
 *  <link rel="stylesheet" href="css/RadialMenu.css" />
 *  <link rel="stylesheet" href="css/font-awesome.min.css" />
 *  2. Deploy menu
 *  var radialMenu = new RadialMenu("#containerElement", arrayOfLinkObjects);
 *  3. DO NOT PUT unsanitated data in the links-parameter!
 *
 *  @param {jQuery selector or element} container, where to append this radial menu?
 *  @param {Array of Objects} links, each Object represents a link inside the radial menu.
 *              Object keys are put to link attributes, eg. <a <attribute>="<value>">...
 *              Some object properties/keys have special significance:
 *              "_text": "This is the content of the link, what is inserted between the <a></a> tags",
 *              "events" {   //All the events to bind to the given link
 *                click: function () {},
 *                ...
 *              }
 */
RadialMenu = function (container, links) {
    var self = this;
    this.container = $(container);

    this.template = function () {
        var html =  '<nav class="circular-menu">\n'+
                    '  <div class="circle">\n';
        links.forEach(function (v,i,a) {
            html += '    '+self.template_link(v)+'\n';
        });
        html +=     '  </div>\n'+
                    '  <a title="Remote repository operations" href="" class="menu-button fa fa-book fa-3x"></a>\n'+
                    '</nav>\n';
        return html;
    };
    this.template_link = function (link) {
        if (!link.href) {            link.href = '#';        }
        var html = '<a ';
        var text;
        Object.keys(link).forEach(function(k,i,a) {
            if (k == "_text") {
                text = link[k];
            }
            else if (k == "events") {
                //process events later
            }
            else { //Concatenate other attributes
                html += k+'="'+link[k]+'" ';
            }
        });
        html += '>'+(text || '')+'</a>';
        return html;
    };
    this.bindEvents = function () {
        links.forEach(function (link,i,a) {
            if (link.events) {
                var linkElement;
                Object.keys(link.events).forEach(function(eventName,i,a) {
                    var callback = link.events[eventName];
                    if (link.id) {
                        linkElement = self.container.find("#"+link.id);
                    }
                    else if (link.class) {
                        var classSelector = '.'+link.class.replace(/\s+/g, '.');
                        linkElement = self.container.find(classSelector);
                    }
                    else {
                        alert("RadialMenu.bindEvents():> Cannot bind event '"+eventName+"' to link because the link doesn't have a class or an id");
                    }

                    if (linkElement.length > 0) {
                        $(linkElement).bind(eventName, callback);
                    }
                    else {
                        alert("RadialMenu.bindEvents():> No link element found for event '"+eventName+"'");
                    }
                });
            }
        });

        //On click, expand selections
        this.container.find(".menu-button").click(function(event) {
            event.preventDefault(); document.querySelector('.circular-menu .circle').classList.toggle('open');
        });

        //Scatter items around the center button
        var items = document.querySelectorAll('.circular-menu .circle a');
        for(var i = 0, l = items.length; i < l; i++) {
          items[i].style.left = (50 - 65*Math.cos(-0.5 * Math.PI - 2*(1/8)*i*Math.PI)).toFixed(4) + "%";
          items[i].style.top = (50 + 65*Math.sin(-0.5 * Math.PI - 2*(1/8)*i*Math.PI)).toFixed(4) + "%";
        }
    };
    this.container.append( this.template() );
    this.bindEvents();
    this.container.draggable({
        start: function( event, ui ) {}
    });
}