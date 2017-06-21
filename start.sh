touch package.json
echo '{
	"name": "",
	"version": "0.0.1",
	"description": "",
	"main": "index.js",
	"scripts": {
		"front": "NODE_ENV=development node frontServer.js",
		"start": "node server.js",
		"build": "NODE_ENV=production webpack --progress --display-error-details --colors ",
		"test": "echo \"Error: no test specified\" && exit 1"
	},
	"author": "",
	"license": "ISC",
	"dependencies": {
		"express": ">=3.0.0",
		"path": "^0.12.7"
	},
	"devDependencies": {
		"babel-core": "^6.22.1",
		"babel-loader": "^6.2.10",
		"babel-polyfill": "^6.22.0",
		"babel-preset-es2015": "^6.22.0",
		"css-loader": "^0.26.1",
		"extract-text-webpack-plugin": "2.0.0-beta.4",
		"file-loader": "^0.10.0",
		"json-loader": "^0.5.4",
		"style-loader": "^0.13.1",
		"webpack": "^2.2.1",
		"webpack-dev-server": "^1.16.3",
		"webpack-dev-middleware": "^1.10.2",
		"webpack-hot-middleware": "^2.18.0"
	}
}' >> package.json
touch webpack.config.js
echo "const webpack = require('webpack');
const path = require('path');
const config = require('./config.json');
const ExtractTextPlugin = require('extract-text-webpack-plugin');

const PATHS = {
	src         : path.resolve(__dirname, 'front/src'),
    dist        : path.resolve(__dirname, 'front/dist'),
    node_modules: path.resolve(__dirname, 'node_modules')
};

const options = {
    production  : (process.env.NODE_ENV === 'production'),
    port        : config.port
};

module.exports = ((options) => {
    let webpackConfig = {};

    webpackConfig.entry = {
        app: options.production ?
            [
                'babel-polyfill',
                path.resolve(PATHS.src, 'js/index.js')
            ] : [
                'babel-polyfill',
                // 'webpack-dev-server/client?https://localhost:' + 'options.port',
                // 'webpack/hot/only-dev-server',
                path.resolve(PATHS.src, 'js/index.js')
            ]
    };

    webpackConfig.output = {
        path        : PATHS.dist,
        publicPath  : './',
        filename    : 'bundle.js'
    };

    webpackConfig.devtool = options.production ? 'nosources-source-map' : 'cheap-module-source-map';

    webpackConfig.plugins = [
        new webpack.optimize.OccurrenceOrderPlugin(),
        new webpack.ProgressPlugin(function (percentage, msg) {
            process.stdout.clearLine();
            process.stdout.cursorTo(0);
            process.stdout.write((percentage * 100).toFixed(2) + '%' + msg);
        }),
        new webpack.DefinePlugin({
            'process.env': {
                'NODE_ENV': options.production ? JSON.stringify('production') : JSON.stringify('development')
            },
            __PRODUCTION__  : JSON.stringify(options.production),
            __SOCKET_URL__  : JSON.stringify(config.socketURL),
            __API_URL__     : JSON.stringify(config.apiURL)
        }),
        new ExtractTextPlugin('style.css')
    ];

    if(options.production){
        webpackConfig.plugins.push(
            new webpack.optimize.UglifyJsPlugin({
                minimize: true,
                compressor: {
                    warnings: false
                },
                sourceMap: false
            })
        );
    } else {
        webpackConfig.plugins.push(
            new webpack.HotModuleReplacementPlugin()
        );
    }

    webpackConfig.module = {
        rules: [
            {
                test    : /\.(ico)$/,
                include : PATHS.src,
                loader  : 'file-loader',
                options : {
                    name : '[name].[ext]'
                }
            },
            {
                test    : /\.css$/,
                include : path.resolve(PATHS.dist, 'css'),
                loader  : ExtractTextPlugin.extract({ fallbackLoader: 'style-loader', loader: 'css-loader' })
            },
            {
                test    : /\.(png|gif|jpg)$/,
                loader  : 'file-loader'
            },
            {
                test    : /\.(js|jsx)$/,
                loader  : 'babel-loader',
                include : PATHS.src
            }
        ]
    };

    webpackConfig.resolve = {
        enforceExtension: false,
        extensions: ['.js', '.jsx', '.json'],
        modules: ['node_modules'],
        alias: {
            app         : PATHS.src
        }
    };

    return webpackConfig;
})(options);" >> webpack.config.js
mkdir front
mkdir server
touch server.js
echo "const path = require('path');
const express = require('express');
const webpack = require('webpack');
const webpackDevMiddleware = require('webpack-dev-middleware');
const webpackHotMiddleware = require('webpack-hot-middleware');

const config = require('./webpack.config.js');
const configConst = require('./config.json');

const 	app 			= express(),
		compiler 		= webpack(config),
		isDevelopment 	= process.env.NODE_ENV !== 'production';
		
global.PATH  = {
	app: 	__dirname,
	front: 	path.join(__dirname, 'front')
}

if (isDevelopment) {

	app.use(webpackDevMiddleware(compiler, {
		publicPath: config.output.publicPath
	}));
	app.use(webpackHotMiddleware(compiler));
}

app.use('', express.static(PATH.front));
app.get('/',function(req, res){
	res.sendFile(path.join(PATH.front, 'index.html'));
});

app.listen(configConst.port, function () {
	console.log('Example app listening on port ' + configConst.port);
});" >> server.js
touch frontServer.js
echo "const path = require('path');
const express = require('express');
const webpack = require('webpack');
const webpackDevMiddleware = require('webpack-dev-middleware');
const webpackHotMiddleware = require('webpack-hot-middleware');

const config = require('./webpack.config.js');
const configConst = require('./config.json');

const 	app 			= express(),
		compiler 		= webpack(config),
		isDevelopment 	= process.env.NODE_ENV !== 'production';
		
global.PATH  = {
	app: 	__dirname,
	front: 	path.join(__dirname, 'front')
}

if (isDevelopment) {

	app.use(webpackDevMiddleware(compiler, {
		publicPath: config.output.publicPath
	}));
	app.use(webpackHotMiddleware(compiler));
}

app.use('', express.static(PATH.front));
app.get('/',function(req, res){
	res.sendFile(path.join(PATH.front, 'index.html'));
});

app.listen(configConst.port, function () {
	console.log('Example app listening on port ' + configConst.port);
});" >> frontServer.js
touch config.json
echo '{
	"port": 8085,
	"apiURL": 3001
}' >> config.json
touch .gitignore
echo "node_modules
front/dist/*
npm-debug.log
package-lock.json" >> .gitignore
touch .babelrc
echo '{ "presets" : [ "es2015" ]}' >> .babelrc
touch .jshint
echo '{
	"node": true, 
	"browser": true, 
	"esnext": true,
	"bitwise": true,
	"curly": false,
	"eqeqeq": true,
	"latedef": true,
	"quotmark": "single",
	"undef": true,
	"unused": true,
	"smarttabs": true,
	"asi": false,
	"indent": true,
	"noempty": true
}' >> .jshint
cd server
mkdir controllers
mkdir models
cd ../front
mkdir src
mkdir dist
touch index.html
echo '<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
	<link rel="stylesheet" href="dist/styles.css">
	<title></title>
</head>
<body>
	<div id="root">Hello!</div>
	<script src="dist/bundle.js"></script>
</body>
</html>' >> index.html
cd dist 
touch styles.css
touch bundle.js
mkdir images
cd ../src
mkdir css
mkdir js
cd js
touch index.js
cd ../css
touch common.css
touch normalize.css
cd ../../..
rm -rf start.sh







