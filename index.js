'use strict';

const Argv = require('minimist')(process.argv.slice(2));
const Helmet = require('helmet');
const Express = require('express');
const Proxy = require('http-proxy-middleware');
const App = Express();
const Url = require('url');

App.use(Helmet());
App.disable('x-powered-by');

let lastRefererBasePath = '';
let proxy = Proxy({
    target:       'http://127.0.0.1:8002/read-file/',
    changeOrigin: true,
    pathRewrite:  function (path, req) {
        // console.log('path', path);
        if (!req.headers['referer']) return path;
        let uri = Url.parse(req.headers['referer']);
        // console.log('');

        // detect root path (thuong it hon 4 /)
        // console.log('path.split.length', path.split('/').length);
        if (path.split('/').length > 4) return path;

        let parts = uri.pathname.split('/');
        parts.pop(); // remove filename

        // console.log('parts.length', parts.length);
        if (parts.length >= 4) {
            lastRefererBasePath = parts.join('/');
        }

        let newPath = lastRefererBasePath + path;
        // console.log(req.headers['referer']);
        // console.log('path', path, 'newPath', newPath);
        return newPath;
    },
    // pathRewrite:  {
    //     '^/proxy': '',
    //     '^/css':   '/qq/demo-deploy-github/build/css',
    //     '^/js':    '/qq/demo-deploy-github/build/js',
    //     '^/img':   '/qq/demo-deploy-github/build/img',
    //     '^/fonts': '/qq/demo-deploy-github/build/fonts',
    // },
    router:       {
        // 'localhost:8888' : '127.0.0.1:8002/read-file/'
    }
});

App.use('/ide', Express.static('web'));

App.all('*', proxy);


const PORT = Argv.PORT || 8888;

let listener = App.listen(PORT, function () {
    let address = listener.address();
    console.log(`app listening at ${address.address}:${address.port}`);
});
