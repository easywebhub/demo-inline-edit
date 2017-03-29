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

function createProxyHandler(target) {
    return Proxy({
        target:       target,
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
            if (parts.length === 4 && parts[3] === 'build') {
                lastRefererBasePath = parts.join('/');
            }

            let newPath = lastRefererBasePath + path;
            // console.log(req.headers['referer']);
            console.log('path', path, 'newPath', newPath);
            if (path.startsWith('/css/')
                || path.startsWith('/js/')
                || path.startsWith('/fonts/')
                || path.startsWith('/vendors/')
                || path.startsWith('/assets/')
                || path.startsWith('/img/')
            ) {
                // trim after /build/
                // var start = lastRefererBasePath.
                // path =
                // console.log('newPath', newPath);
                return newPath;
            } else {
                // console.log('newPath', newPath);
                return newPath;
            }
        }
    });
}

let proxyGet = createProxyHandler('http://127.0.0.1:8002/read-file/');
let proxyPost = createProxyHandler('http://127.0.0.1:8002/write-file/');

App.use('/ide', Express.static('web'));

App.get('*', proxyGet);
App.post('*', proxyPost);

const PORT = Argv.PORT || 8888;

let listener = App.listen(PORT, '0.0.0.0', function () {
    let address = listener.address();
    console.log(`app listening at ${address.address}:${address.port}`);
});
