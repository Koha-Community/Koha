#!/usr/bin/env python
#Last-update: 08/05/07 12:39:17
import re
import sys
from sets import Set

##
# External files
#
AJS_SRC = 'AJS.js'
AJS_MINI_SRC = 'AJS_compressed.js'


##
# Standard stuff that may change in the future
#
DOM_SHORTCUTS = [
    "ul", "li", "td", "tr", "th",
    "tbody", "table", "input", "span", "b",
    "a", "div", "img", "button", "h1",
    "h2", "h3", "br", "textarea", "form",
    "p", "select", "option", "iframe", "script",
    "center", "dl", "dt", "dd", "small",
    "pre", "tn"
]

FN_SHORTCUTS = {
    '$': 'getElement',
    '$$': 'getElements',
    '$f': 'getFormElement',
    '$b': 'bind',
    '$p': 'partial',
    '$A': 'createArray',
    'DI': 'documentInsert',
    'ACN': 'appendChildNodes',
    'RCN': 'replaceChildNodes',
    'AEV': 'addEventListener',
    'REV': 'removeEventListener',
    '$bytc': 'getElementsByTagAndClassName'
}

AJS_TEMPLATE = """//AJS JavaScript library (minify'ed version)
//Copyright (c) 2006 Amir Salihefendic. All rights reserved.
//Copyright (c) 2005 Bob Ippolito. All rights reserved.
//License: http://www.opensource.org/licenses/mit-license.php
//Visit http://orangoo.com/AmiNation/AJS for full version.
AJS = {
BASE_URL: "",
drag_obj: null,
drag_elm: null,
_drop_zones: [],
_cur_pos: null,

%(functions)s
}

AJS.$ = AJS.getElement;
AJS.$$ = AJS.getElements;
AJS.$f = AJS.getFormElement;
AJS.$p = AJS.partial;
AJS.$b = AJS.bind;
AJS.$A = AJS.createArray;
AJS.DI = AJS.documentInsert;
AJS.ACN = AJS.appendChildNodes;
AJS.RCN = AJS.replaceChildNodes;
AJS.AEV = AJS.addEventListener;
AJS.REV = AJS.removeEventListener;
AJS.$bytc = AJS.getElementsByTagAndClassName;

AJS.addEventListener(window, 'unload', AJS._unloadListeners);
AJS._createDomShortcuts();

%(AJSClass)s

%(AJSDeferred)s
script_loaded = true;
"""


def getAjsCode():
    return open(AJS_SRC).read()

def writeAjsMini(code):
    open(AJS_MINI_SRC, "w").write(code)


class AjsAnalyzer:

    def __init__(self):
        self.code = getAjsCode()
        self.ajs_fns = {}
        self.ajs_deps = {}
        self._parseAJS()
        self._findDeps()

    def _parseAJS(self):
        ajs_code = re.search("AJS =(.|\n)*\n}\n", self.code).group(0)
        fns = re.findall("\s+((\w*?):.*?{(.|\n)*?\n\s*})(,|\n+})\n", ajs_code)
        for f in fns:
            self.ajs_fns[f[1]] = f[0]

    def getFnCode(self, fn_name, caller=None):
        """
        Returns the code of function and it's dependencies as a list
        """
        fn_name = self._unfoldFn(fn_name)
        r = []
        if self.ajs_fns.get(fn_name):
            r.append(self.ajs_fns[fn_name])
            for dep_fn in self.ajs_deps[fn_name]:
                if fn_name != dep_fn and dep_fn != caller:
                    r.extend(self.getFnCode(dep_fn, fn_name))
        elif fn_name not in ['listeners', 'Class']:
            print 'Could not find "%s"' % fn_name
        return r

    def getAjsClassCode(self):
        return re.search("AJS.Class =(.|\n)*\n};\n", self.code).group(0)

    def getAjsDeferredCode(self):
        return re.search("AJSDeferred =(.|\n)*\n};\n", self.code).group(0)

    def _findDeps(self):
        """
        Parses AJS and for every function it finds dependencies for the other functions.
        """
        for fn_name, fn_code in self.ajs_fns.items():
            self.ajs_deps[fn_name] = self._findFns(fn_code)

    def _findFns(self, inner):
        """
        Searches after AJS.fnX( in inner and returns all the fnX in a Set.
        """
        s = re.findall("AJS\.([\w_$]*?)(?:\(|,|\.)", inner)
        s = list(Set(s))
        return self._unfoldFns(s)

    def _unfoldFns(self, list):
        """
        Unfolds:
            AJS.B, AJS.H1 etc. to _createDomShortcuts
            AJS.$ to AJS.getElement etc.
        """
        return [self._unfoldFn(n) for n in list]

    def _unfoldFn(self, fn_name):
        if fn_name.lower() in DOM_SHORTCUTS:
            return "_createDomShortcuts"
        elif FN_SHORTCUTS.get(fn_name):
            return FN_SHORTCUTS[fn_name]
        else:
            return fn_name


class ExternalCodeAnalyzer:

    def __init__(self, files):
        self.found_ajs_fns = []
        self.files = files

    def findFunctions(self):
        for f in self.files:
            self.found_ajs_fns.extend( self._parseFile(f) )
        return list(Set(self.found_ajs_fns))

    def _parseFile(self, f):
        """
        Parses the file, looks for AJS functions and returns all the found functions.
        """
        code = open(f).read()
        return re.findall("AJS\.([\w_$]*?)\(", code)



class AjsComposer:

    def __init__(self, fn_list):
        self.code = getAjsCode()
        self.analyzer = AjsAnalyzer()
        self.fn_list = fn_list

        #Append standard functions
        req = ['_unloadListeners', 'createDOM', '_createDomShortcuts', 'log', 'addEventListener']
        self.fn_list.extend(req)

        #Append AJSDeferred only if needed
        in_list = lambda x: x in self.fn_list
        if in_list('getRequest') or in_list('loadJSONDoc'):
            self.deferred = self._minify(self.analyzer.getAjsDeferredCode())
            self.fn_list.append('isObject')
        else:
            self.deferred = ''

    def writeToOutput(self):
        fns = self._getFns()
        d = {}
        d['functions'] = ",\n".join(fns)
        d['AJSDeferred'] = self.deferred
        d['AJSClass'] = self.analyzer.getAjsClassCode()

        mini_code = AJS_TEMPLATE % d
        writeAjsMini(mini_code)

    def _minify(self, code):
        new_lines = []
        for l in code.split("\n"):
            if l not in ['\n', '']:
                new_lines.append(l.lstrip())
        return "\n".join(new_lines)

    def _getFns(self):
        """
        Returns a list with real code of functions
        """
        r = []
        for fn in self.fn_list:
            r.extend(self.analyzer.getFnCode(fn))

        r = list(Set(r))
        return [self._minify(fn) for fn in r]


if __name__ == '__main__':
    args = sys.argv

    if len(args) < 3:
        print """Usage is:
    python AJS_minify.py [-o output_file] ajs_file js_file.js html_using_ajs.html ...
Example usage:
    Using relative paths:
        python AJS_minify.py -o AJS_mini.js AJS.js test.js index.html
        This will create AJS_mini.js from test.js and index.html.
    Using absolute paths:
        python AJS_minify.py ~/Desktop/AJS/AJS.js ~/Desktop/GreyBox_v3_42/greybox/greybox.js
        This will create a new file called '%s' that has the needed AJS functions.""" % AJS_MINI_SRC

        sys.exit(0)

    if sys.argv[1] == '-o':
        AJS_MINI_SRC = sys.argv[2]
        AJS_SRC = sys.argv[3]
        FILES = sys.argv[4:]
    else:
        AJS_SRC = sys.argv[1]
        FILES = sys.argv[2:]

    print 'Parsing through:\n    %s' % "\n    ".join(FILES)

    code_analyzer = ExternalCodeAnalyzer(FILES)
    found_fns = code_analyzer.findFunctions()
    print 'Found following AJS functions:\n    %s' % ("\n    ".join(found_fns))

    composer = AjsComposer(found_fns)
    composer.writeToOutput()
    print "Written the minified code to '%s'" % AJS_MINI_SRC
