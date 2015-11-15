//Package Serials.CollectionMap
if (typeof Serials == "undefined") {
    this.Serials = {}; //Set the global package
}
Serials.CollectionMap = {

    /**
     * Represents the serials in our database in a graph form.
     * @constructor
     * @param {jQuery Node} root element - In which element will this map be built into.
     * @param {long} biblionumber - For which Biblio is this graph generated for?
     * @param {function} callback - the callback function to call when this object has been constructed.
     *        the callback function gets two parameters:
     *        @param {CollectionMap} this - This object just created.
     *        @param {String} errorString - "undefined" if nothing bad happened, otherwise the error description.
     */
    CollectionMap: function(node, biblionumber, callback) {
        this.node = node;
        this.biblionumber = biblionumber;
        this.subscribers = [];
        if (typeof callback == "function") {
            this.events.callback = callback;
        }
        else if (typeof callback == "undefined") {
            //it is ok if there is no callback
        }
        else {
            alert("CollectionMap.CollectionMap(node, biblionumber, callback):> Callback is not a 'function' or 'undefined'!");
        }
        Serials.CollectionMap._initAjax(this);
    },
    _create: function(self) {
        Serials.CollectionMap._jstreeifyCollectionMap(self);
        Serials.CollectionMap._render(self);
        Serials.CollectionMap._bindEvents(self);
    },

    /**
     * Adds a Subscriber to the events of this CollectionMap. When events occur,
     * CollectionMap calls the publish()-function of the Listener with the following parameters:
     *        {CollectionMap} this object which initiated the call.
     *        {data} data related to the event
     *        {event} data related to the event.
     *
     * @param {CollectionMap-object} this object
     * @param {Listener-object} Any object which is configured to subscribe to a CollectionMap
     */
    subscribe: function(self, subscriber) {
        self.subscribers.push( subscriber );
    },
    unsubscribe: function(self, subscriber) {
        for (var i=0 ; i<self.subscribers.length ; i++) {
            var subscribingSubscriber = self.subscribers[i];
            if (subscriber === subscribingSubscriber) {
                self.subscribers.splice(i,1);
                break;
            }
        }
    },

    /**
     * Publishes a publication to all subscribers.
     */
    publicate: function (self, data, event) {
        for (var i=0 ; i<self.subscribers.length ; i++) {
            var subscriber = self.subscribers[i];
            subscriber.publish(self, data, event );
        }
    },

    /**
     * Fetches the serial collection map from the Koha REST API.
     * Calls the callback function after everything is ok or failed.
     */
    _initAjax: function(self) {
        $.ajax("/api/v1/serials/collection",
                { "method": "get",
                  "accepts": "application/json",
                  "data": {
                    "biblionumber": self.biblionumber,
                    "serialStatus": 2, //Get only arrived serials
                  },
                  "success": function (jqXHR, textStatus, errorThrown) {
                    self.map = jqXHR.collectionMap;
                    Serials.CollectionMap._create(self);
                    if (typeof callback == "function") {
                        callback(self, errorThrown);
                    }
                  },
                  "error": function (jqXHR, textStatus, errorThrown) {
                    alert("Serials.CollectionMap._initAjax():> "+errorThrown);
                    if (typeof callback == "function") {
                        callback(self, errorThrown);
                    }
                  },
                }
        );
    },

    /**
     * Creates the html-elements necessary to display this graph.
     */
    _render: function(self) {
        self.jstree = $(self.node).jstree({
            core: {
                data: self.jstreeNodes,
            },
            //Sort descending
            sort: function(a,b) {
                    var comparisonResult = Serials.CollectionMap._sortDescendingByStackedValues(this, a, b);

                    if (comparisonResult == 0) {
                        return 1;
                    }
                    else {
                        return comparisonResult;
                    }
            },
            plugins: ["sort"],
        });
    },

    /**
     * Bind event handlers to the CollectionMap-object
     */
    _bindEvents: function (self) {
        $(self.node)
        //When a node is clicked or interacted with
        .on('activate_node.jstree', function (what, data){
            if (data.node.children.length > 0) {
                //This is not a leaf node.
                return;
            }
            var node_id = data.node.id;
            var serialseqs_xyz = node_id.split(":");
            Serials.CollectionMap.displaySerialItems(self, {serialseq_x: serialseqs_xyz[0],
                                                            serialseq_y: serialseqs_xyz[1],
                                                            serialseq_z: serialseqs_xyz[2],
                                                            biblionumber: self.biblionumber,
                                                        }
                                                    );
        });
    },

    /**
     * Fetches, prepares and displays serialItems in the Items-table for the
     * given serial issue.
     * @param {CollectionMap} This object.
     * @param {Object} parameters:
     *        @key 'serialseq_x', the first serial issue enumeration field, typically the year.
     *        @key 'serialseq_y', the second enumeration, eg volume.
     *        @key 'serialseq_z', the third enumeration.
     *        @key 'biblionumber', biblionumber of the Biblio whose serialItems need displaying.
     * @param {Object} serialItems, the serialItems to display. If these are not given, we request them from the server.
     */
    displaySerialItems: function(self, params, serialItems) {
        if (typeof serialItems !== "undefined") {
            Serials.CollectionMap.publicate(self, serialItems, 'display');
        }
        else {
            Serials.CollectionMap.getSerialItems(self, params);
        }
    },

    /**
     * Make an ajax-call to the REST API to fetch the serialItems
     * See @params of displaySerialItems()
     */
    getSerialItems: function(self, params) {
        $.ajax("/api/v1/serialitems",
            {   "method": "get",
                "accepts": "application/json",
                "data": {
                    biblionumber: params.biblionumber,
                    serialseq_x: params.serialseq_x,
                    serialseq_y: params.serialseq_y,
                    serialseq_z: params.serialseq_z,
                    serialStatus: 2, //Receive only arrived serials
                },
                "success": function (jqXHR, textStatus, errorThrown) {
                    Items.Cache.clear();
                    Items.Cache.addLocalItems(jqXHR.serialItems);
                    //Recurse back to displaySerialItems(), this time with payload!
                    Serials.CollectionMap.displaySerialItems(self, params, jqXHR.serialItems);
                },
                "error": function (jqXHR, textStatus, errorThrown) {
                    alert("Serials.CollectionMap.getSerialItems():> "+errorThrown);
                },
            }
        );
    },

    /**
     * Prepare the CollectionMap to a jstree-nodeslist
     */
    _jstreeifyCollectionMap: function(self) {
        var jstreeNodes = [];

        function recurseNode(collectionsMap, depth, parentKey, parentNode, nodeKey, node) {
            node.id     = (parentNode) ? parentNode.id   + ":" + nodeKey : nodeKey;
            node.text   = (parentNode) ? parentNode.text + ":" + nodeKey : nodeKey;
            node.parent = (parentNode) ? parentNode.id : "#";

            //Prepare the list of serial enumeration elements.
            if (parentNode && parentNode.serialseqs) {
                node.serialseqs = parentNode.serialseqs.slice(0);
            }
            else {
                node.serialseqs = [];
            }
            node.serialseqs.push(nodeKey);

            if (node.childs) {
                jstreeNodes.push( node );
                for (var childKey in node.childs) {
                    var childNode = node.childs[childKey];
                    recurseNode(collectionsMap, depth+1, nodeKey, node, childKey, childNode);
                }
            }
            else {
                dealWithLeafNode(collectionsMap, depth, parentKey, parentNode, nodeKey, node);
            }
        }
        function dealWithLeafNode(collectionsMap, depth, parentKey, parentNode, nodeKey, node) {
            if (node.arrived) {
                node.text = node.text;
            }
            else {
                log.warn("CollectionMap._jstreeifySerialItems():> Leaf node '"+node.id+"' has no 'arrived'-property!");
            }
            jstreeNodes.push(node);
        }

        for (var key in self.map) {
            var node = self.map[key];
            recurseNode(self, 1, null, null, key, node);
        }

        self.jstreeNodes = jstreeNodes;
        return jstreeNodes;
    },
    /**
     * Each sortable element has a stack of values identifying the elements' sequential
     * position in a deep hash. We must sort the elements based on the internal stack
     * locations, instead of the textual presentations, since they can be very different.
     */
    _sortDescendingByStackedValues (jstree, a, b) {
        var a_seqs = jstree.get_node(a).original.serialseqs;
        var b_seqs = jstree.get_node(b).original.serialseqs;
        var i = 0;
        var comparisonResult;
        do {
            var a_comparable = a_seqs[i];
            var b_comparable = b_seqs[i];
            a_comparable = (isNaN(a_comparable) ? parseInt(a_comparable) : a_comparable);
            b_comparable = (isNaN(b_comparable) ? parseInt(b_comparable) : b_comparable);
            comparisonResult = (Number(a_comparable) > Number(b_comparable) ? -1 :
                                    (Number(a_comparable) == Number(b_comparable) ? 0 : 1)
                                );
            i++;
        } while (comparisonResult == 0 && a_comparable && b_comparable);
        return comparisonResult;
    }
};
