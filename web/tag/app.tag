<app>
    <div ref="main" class="ui grid" style="margin: 0; display: none">
        <div class="sixteen wide column" style="padding: 0; display: flex;">
            <div data-is="sidebar" site-builder-url="{opts.siteBuilderUrl}"></div>
            <div data-is="iframe-inline-editor" site-builder-url="{opts.siteBuilderUrl}"></div>
        </div>
    </div>
    <div data-is="dialog-choose-site" site-builder-url="{opts.siteBuilderUrl}"></div>

    <script>
        var me = this;

        var sideBar, editor, sitePath;

        me.on('selectFile', function (fileName, filePath) {
            console.log('select file', fileName, filePath);
            // remove 'repository' from filePath
            var parts = filePath.split('.');
            parts.pop(); // remove file extension '.md'
            var slug = parts.join('.').split('/').pop();

            var pageUrl = me.sitePath
                + '/build/'
                + slug;

            if (pageUrl.endsWith('/index'))
                pageUrl += '.html';

            if (!pageUrl.endsWith('/index.html'))
                pageUrl += '/index.html';

            console.log('pageUrl', pageUrl);
            editor.setUrl(pageUrl);
        });

        me.on('chooseSite', function (sitePath) {
            console.log('chooseSite', sitePath);
            me.sitePath = sitePath;
            me.tags['dialog-choose-site'].hide();

            $(me.refs['main']).show();

            var fileListUrl = me.opts.siteBuilderUrl + '/read-dir/' + sitePath + '/content';
            console.log('fileListPath', fileListUrl);

            var indexUrl = sitePath + '/build/index.html';
            if (!indexUrl.startsWith('/')) indexUrl = '/' + indexUrl;
            console.log('indexUrl', indexUrl);
            editor.setUrl(indexUrl);

            axios.get(fileListUrl).then(function (resp) {
                var files = resp.data.result;
                sideBar.loadFiles(files);
            });

            Split([sideBar.root, editor.root], {
                direction:  'horizontal',
                snapOffset: 0,
                sizes:      [20, 80],
                minSize:    [200, 300],
                gutterSize: 6
            });
        });

        me.on('startBuild', function () {
            console.log('startBuild', 'http://dummy.com/' + me.sitePath);
            axios.post(me.opts.siteBuilderUrl + '/build', {
                repoUrl: 'http://dummy.com' + me.sitePath,
                task:    'metalsmith'
            }).then(function (resp) {
                console.log('build success', resp);
                editor.trigger('endBuild', true);
            }).catch(function (error) {
                console.log('error');
                editor.trigger('endBuild', false);
            });
        });

        me.on('mount', function () {
            sideBar = me.tags['sidebar'];
            editor = me.tags['iframe-inline-editor'];


            // handle if url have username and repository info
            var parts = document.location.pathname.split('/');
            if (parts.length >= 4) {
                var username = parts[2];
                var repository = parts[3];
                sitePath = username + '/' + repository;
                if (!sitePath.startsWith('/')) sitePath = '/' + sitePath;
                setTimeout(function () {
                    me.trigger('chooseSite', sitePath);
                });
            } else {
                // wait for dialog-choose-site mount
                setTimeout(function () {
                    me.tags['dialog-choose-site'].show();
                });
            }

//            setTimeout(function () {
//                me.trigger('chooseSite', '/qq/demo-deploy-github');
//            });
        });

        me.on('unmount', function () {

        });
    </script>

    <style>
        app {
            -webkit-box-sizing: border-box;
            -moz-box-sizing: border-box;
            box-sizing: border-box;
        }

        .gutter {
            background-color: #eee;
            display: inline-block;

            background-repeat: no-repeat;
            background-position: 50%;
            height: 100vh;
        }

        .gutter.gutter-horizontal {
            background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAeCAYAAADkftS9AAAAIklEQVQoU2M4c+bMfxAGAgYYmwGrIIiDjrELjpo5aiZeMwF+yNnOs5KSvgAAAABJRU5ErkJggg==');
            cursor: ew-resize;
        }

        .gutter.gutter-vertical {
            background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAFAQMAAABo7865AAAABlBMVEVHcEzMzMzyAv2sAAAAAXRSTlMAQObYZgAAABBJREFUeF5jOAMEEAIEEFwAn3kMwcB6I2AAAAAASUVORK5CYII=');
            cursor: ns-resize;
        }
    </style>
</app>
