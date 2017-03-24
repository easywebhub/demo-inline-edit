<app>
    <div class="ui grid" style="margin: 0">
        <div class="sixteen wide column" style="padding: 0; display: flex;">
            <div data-is="sidebar"></div>
            <div data-is="iframe-inline-editor"></div>
        </div>
    </div>

    <script>
        var me = this;

        var sideBar, editor;

        me.on('mount', function () {
            sideBar = me.tags['sidebar'];
            editor = me.tags['iframe-inline-editor'];

//            console.log('tags', me.tags);
//            console.log('sideBar', sideBar);
//            console.log('editor', editor);
            axios.get('http://127.0.0.1:8002/read-dir/qq/demo-deploy-github/content').then(function (resp) {
                var files = resp.data.result;
                sideBar.loadFiles(files);
//                console.log('data', data);
            });

            Split([sideBar.root, editor.root], {
                direction:  'horizontal',
                snapOffset: 0,
                sizes:      [20, 80],
                minSize:    [200, 300],
                gutterSize: 6
            });
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
