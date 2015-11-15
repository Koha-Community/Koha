//Package Branches
if (typeof Branches == "undefined") {
    this.Branches = {}; //Set the global package
}

var log = log;
if (!log) {
    log = log4javascript.getDefaultLogger();
}

Branches.branchSelectorHtml = null; //The unattached template
Branches.getBranchSelectorHtml = function (branches, id, loggedinbranch) {
    var bSelector = Branches.getCachedBranchSelectorHtml(branches, id, loggedinbranch);
    if (!bSelector) {
        bSelector = Branches.createBranchSelectorHtml(branches, id, loggedinbranch);
    }
    return Branches.rebrandBranchSelectorHtml(bSelector, id, loggedinbranch);
}
Branches.createBranchSelectorHtml = function (branches, id, loggedinbranch) {
    var bSelectorHtml = Branches.BranchSelectorTmpl.transform(branches, id, loggedinbranch);
    Branches.cacheBranchSelectorHtml(bSelectorHtml, id, loggedinbranch);
    return bSelectorHtml;
}
Branches.cacheBranchSelectorHtml = function (branchSelector, id, loggedinbranch) {
    Branches.branchSelector = branchSelector;
}
Branches.getCachedBranchSelectorHtml = function (branchSelector, id, loggedinbranch) {
    return Branches.branchSelector;
}
Branches.rebrandBranchSelectorHtml = function (branchSelectorHtml, id, loggedinbranch) {
    return branchSelectorHtml.replace('id="branchSelectorTemplate"', 'id="'+id+'"');
}



//Package Branches.BranchSelectorTmpl
if (typeof Branches.BranchSelectorTmpl == "undefined") {
    this.Branches.BranchSelectorTmpl = {}; //Set the global package
}

/**
 * @returns {String HTML} the unattached HTML making up the BranchSelector.
 */
Branches.BranchSelectorTmpl.transform = function (branches, id, loggedinbranch) {
    var html =
    '<select size="1" id="branchSelectorTemplate">';
    for (var i=0 ; i<branches.length ; i++) { var branch = branches[i];
        if (branch.branchcode === loggedinbranch) {
            branch.selected = true;
        }
        html +=
        '<option value="'+branch.branchcode+'" '+(branch.selected ? 'selected="selected"' : '')+'>'+branch.branchname+'</option>';
    }
    html +=
    '</select>';
    return html;
}
