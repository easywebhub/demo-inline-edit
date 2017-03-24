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

        window.onIframeElementEdit = function(event, elm, value) {
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
                while(parts.length > 0) {
                    var node = parts.shift();
                    if (node === 'build') break;
                }
                data.eaSlug = parts.join('/');
            }

            data.eaValue = value;
            me.change = data;
        };

        window.onIframeElementBlur = function(data, editable) {
            console.log('save change', me.change);
        };

        me.on('mount', function () {
            iframe = $(me.root).find('iframe')[0];

            window.iframeInlineEditor = me.refs['iframeInlineEditor'];
            me.refs['iframeInlineEditor'].onload = function () {
                console.log('preview loaded');
                console.log('start inject');

//                injectJS('http://cdn.jsdelivr.net/medium-editor/latest/js/medium-editor.min.js');
//                injectCSS('http://cdn.jsdelivr.net/medium-editor/latest/css/medium-editor.min.css');

                $.get('js/medium-editor.min.js', function (data) {
                    injectJSCode(data);
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
