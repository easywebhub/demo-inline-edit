<iframe-inline-editor style="display: inline-block; padding:0">
    <div class="ui attached segment" style="height: 100vh; padding: 0;">
        <div class="ui top attached label"><h4 class="ui header">Review</h4></div>
        <iframe ref="iframeInlineEditor" src="/qq/demo-deploy-github/build/index.html" style="overflow-x: hidden; padding: 0; height: calc(100vh - 40px); width: 100%; overflow-y: auto; margin: 35px 0 0 !important;">
        </iframe>
    </div>
    <script>
        var me = this;
        var iframe;

        var change = {};

        var FORM_START = /^---json/;
        var FORM_END_1 = /---$/;
        var FORM_END_2 = /---[\r\n]/;

        String.prototype.regexIndexOf = function (regex, startpos) {
            let indexOf = this.substring(startpos || 0).search(regex);
            return (indexOf >= 0) ? (indexOf + (startpos || 0)) : indexOf;
        };

        function splitContentFile(fileContent) {
            var start = fileContent.regexIndexOf(FORM_START);
            if (start == -1) return null;
            start += 7;

            var end = fileContent.regexIndexOf(FORM_END_1, start);
            if (end == -1)
                end = fileContent.regexIndexOf(FORM_END_2, start);
            if (end == -1) return null;
            return {
                metaData:     JSON.parse(fileContent.substr(start, end - start).trim()),
                markDownData: fileContent.substr(end + 3).trim()
            }
        }

        var injectCSS = function (path) {
            var css = iframe.contentWindow.document.createElement('link');
            css.type = 'text/css';
            css.rel = 'stylesheet';
            css.href = path;
            iframe.contentWindow.document.body.appendChild(css);
        };

        var injectCSSStyle = function (style) {
            var css = iframe.contentWindow.document.createElement('style');
            css.innerHTML = style;
            iframe.contentWindow.document.body.appendChild(css);
        };

        var injectJS = function (path) {
            var script = iframe.contentWindow.document.createElement('script');
            script.type = 'text/javascript';
            script.src = path;
            iframe.contentWindow.document.body.appendChild(script);
        };

        var injectJSCode = function (code) {
            var script = iframe.contentWindow.document.createElement('script');
            script.type = 'text/javascript';
            script.innerHTML = code;
            iframe.contentWindow.document.body.appendChild(script);
        };

        var runScript = function (code) {
            var script = iframe.contentWindow.document.createElement('script');
            script.type = 'text/javascript';
            script.innerHTML = code;
            iframe.contentWindow.document.body.appendChild(script);
        };

        function applyNewValue(objectPath, target, newValue) {
            let parts = objectPath.split('.');
            let cur = target;
            let parent = null;
            let found = parts.some(function (key, index) {
                // if key is number (array index)
                if (/^[0-9]+$/g.test(key)) {

                    key = parseInt(key);
                    parent = cur;
                    cur = cur[key];
                    console.log('number', key, cur != undefined && index == parts.length - 1);
                    return cur != undefined && index == parts.length - 1;
                } else if (typeof(key) === 'string') {
                    // text
                    parent = cur;
                    cur = cur[key];
                    console.log('text', key, cur != undefined && index == parts.length - 1);
                    return cur != undefined && index == parts.length - 1;
                } else {
                    return false; // not proccessable key, break
                }
            });
            if (!found) return false;
            let lastKey = parts.pop();
            parent[lastKey] = newValue;
            return true;
        }

        window.onIframeElementEdit = function (event, elm, value) {
            // lay cac data co prefix ea tu element
            var $elm = $(elm);
            var data = $elm.data();
            for (var key in data) {
                if (!data.hasOwnProperty(key)) continue;
                if (!key.startsWith('ea')) delete data[key];
            }

            // tim slug cua trang
            if (data.eaSlug.indexOf('/build/') != -1) {
                var parts = data.eaSlug.split('/');
                while (parts.length > 0) {
                    var node = parts.shift();
                    if (node === 'build') break;
                }
                data.eaSlug = parts.join('/');
            }

            data.eaValue = value;
            me.change = data;
        };

        window.onIframeElementBlur = function (data, editable) {
            // read content file
            //      find content file name
            var fullPath = me.change.eaFullPath;
            var parts = fullPath.split('.');
            parts.pop(); // remove extension
            var contentPath = parts.join('.') + '.md';
            // remove 'build' thay bang 'content'
            contentPath = contentPath.replace(/\/build\//g, '/content/');

            // apply change
            $.get(contentPath, function (contentText) {
//                console.log('contentPath data', content);
                var content = splitContentFile(contentText);
//                console.log('change', me.change);
//                console.log('content', content);
//                console.log('me.change.eaObjectPath', me.change.eaObjectPath);
//                console.log('content.metaData', content.metaData);
//                console.log('me.change.eaValue', me.change.eaValue);
                applyNewValue(me.change.eaObjectPath, content.metaData, me.change.eaValue);

//                console.log('changedValue', content.metaData);

                // create new content and write back
                var newContent = '---json\r\n' + JSON.stringify(content.metaData, null, 4) + '\r\n---\r\n' + content.markDownData;
                console.log('newContent', newContent);

                // write file
                $.ajax({
                    type:        'POST',
                    url:         contentPath,
                    processData: false,
                    data:        newContent
                });
            });

            // write back
        };

        me.on('mount', function () {
            iframe = $(me.root).find('iframe')[0];

            window.iframeInlineEditor = me.refs['iframeInlineEditor'];
            me.refs['iframeInlineEditor'].onload = function () {
                console.log('preview loaded');
                console.log('start inject');

                var jsList = ['js/jquery.min.js', 'js/medium-editor.min.js'];
                jsList.forEach(function (scriptUrl) {
                    $.get(scriptUrl, function (data) {
                        injectJSCode(data);
                    });
                });

                $.get('css/medium-editor.min.css', function (data) {
                    injectCSSStyle(data);
                });

                runScript(`
                    (function defer() { if (!window.MediumEditor) {
                        setTimeout(function () {defer()}, 50); return;}
                        $('*[data-ea-object-path]').each(function(index, elm) {
                            var $elm = $(elm);
                            $elm.attr('data-ea-slug', document.location.pathname);
                            $elm.attr('data-ea-full-path', document.location.pathname);
                            var editor = new MediumEditor(elm);

                            editor.subscribe('editableInput', function(data, editable) {
                                window.parent.onIframeElementEdit(data, editable, elm.innerHTML);
                            });

                            editor.subscribe('blur', function(data, editable) {
                                window.parent.onIframeElementBlur(data, editable, elm.innerHTML);
                            });
                        });
                    })();
                `);
            };
        });

        me.on('unmount', function () {

        });
    </script>

    <style></style>
</iframe-inline-editor>