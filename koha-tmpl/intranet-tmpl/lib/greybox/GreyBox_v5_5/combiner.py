#!/usr/bin/env python
"""
Used to combine the different parts of GreyBox.
- Python 2.4 required
- Java 1.4+ required
- Dojo's JavaScript compressor (http://dojotoolkit.org/docs/compressor_system.html). Place it under compression_lib/custom_rhino.jar
"""
import os, sys, shutil
from compression_lib import AJS_minify


if __name__ == '__main__':
    args = sys.argv

    if len(args) < 2:
        print """
Usage is:
    python combiner.py [full|gallery|window]
Example usage:
    python combiner.py full
The files will be store in greybox_dist/* depending on the dist. type
"""
        sys.exit(0)

    type = args[1]
    output_dir = 'greybox'

    ##
    # Config file list
    #
    js = []
    css = []
    static = []

    append = lambda l, x: l.append('greybox_source/%s' % x)

    def appendBase():
        append(js, 'base/base.js')
        append(js, 'auto_deco.js')
        append(css, 'base/base.css')
        append(static, 'base/indicator.gif')
        append(static, 'base/loader_frame.html')

    def appendSet():
        append(js, 'set/set.js')
        append(css, 'set/set.css')
        append(static, 'set/next.gif')
        append(static, 'set/prev.gif')

    def appendGallery():
        append(js, 'gallery/gallery.js')
        append(css, 'gallery/gallery.css')
        append(static, 'gallery/g_close.gif')

    def appendWindow():
        append(js, 'window/window.js')
        append(css, 'window/window.css')
        append(static, 'window/header_bg.gif')
        append(static, 'window/w_close.gif')

    appendBase()

    if type == 'full':
        appendGallery()
        appendSet()
        appendWindow()
    elif type == 'gallery':
        appendGallery()
        appendSet()
    elif type == 'window':
        appendWindow()
    else:
        sys.exit('Uknown type')

    print 'Follwoing styles are used:'
    for style in css:
        print '   %s' % style

    print 'Follwoing JavaScript is used:'
    for script in js:
        print '   %s' % script

    ##
    # Copy the files
    #
    try:
        shutil.rmtree(output_dir)
    except:
        pass
    os.mkdir(output_dir)

    def concatFiles(f_list):
        data = []
        for f in f_list:
            data.append(open(f, 'r').read())
        return '\n\n'.join(data)

    def copyFiles(f_list):
        for f in f_list:
            shutil.copy(f, output_dir)

    copyFiles(static)
    fp = open('%s/%s' % (output_dir, 'gb_styles.css'), 'w')
    fp.write(concatFiles(css))
    fp.close()
    print 'Compressed styles in %s' % ('greybox/gb_styles.css')

    ##
    # Concat js
    #
    fp = open('%s/%s' % (output_dir, 'gb_scripts_tmp.js'), 'w')
    fp.write(concatFiles(js))
    fp.close()

    AJS_minify.AJS_SRC = 'greybox_source/base/AJS.js'
    AJS_minify.AJS_MINI_SRC = 'greybox/AJS_tmp.js'
    files = ['greybox/gb_scripts_tmp.js', 'greybox_source/base/AJS_fx.js', 'static_files/help.js']
    code_analyzer = AJS_minify.ExternalCodeAnalyzer(files)
    composer = AJS_minify.AjsComposer(code_analyzer.findFunctions())
    composer.writeToOutput()

    os.popen('java -jar compression_lib/custom_rhino.jar -c greybox/AJS_tmp.js > greybox/AJS.js')
    os.remove('greybox/AJS_tmp.js')
    os.popen('java -jar compression_lib/custom_rhino.jar -c greybox_source/base/AJS_fx.js > greybox/AJS_fx.js')
    print 'Compressed AJS.js and AJS.js into greybox/'

    os.popen('java -jar compression_lib/custom_rhino.jar -c greybox/gb_scripts_tmp.js > greybox/gb_scripts.js')
    os.remove('greybox/gb_scripts_tmp.js')
    print 'Compressed JavaScript in %s' % ('greybox/gb_scripts.css')

    #Append script_loaded
    open('greybox/AJS.js', 'a').write('\nscript_loaded=true;')
    open('greybox/AJS_fx.js', 'a').write('\nscript_loaded=true;')
    open('greybox/gb_scripts.js', 'a').write('\nscript_loaded=true;')
