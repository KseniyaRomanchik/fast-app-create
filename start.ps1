New-Item package.json -type file -force
New-Item webpack.config.js -type file -force
Add-Content webpack.config.js 
"const webpack = require('webpack');
const path = require('path');
const config = require('./config.js');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const BundleAnalyzerPlugin = require('webpack-bundle-size-analyzer').WebpackBundleSizeAnalyzerPlugin;

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
                `babel-polyfill`,
                path.resolve(PATHS.src, 'index.js')
            ] : [
                `babel-polyfill`,
                `webpack-dev-server/client?https://localhost:`${options.port}`,
                `webpack/hot/only-dev-server`,
                path.resolve(PATHS.src, 'index.js')
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
            process.stdout.write(`${(percentage * 100).toFixed(2)}% `${msg}`);
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
})(options);"

New-Item front -type directory -force
New-Item server -type directory -force
New-Item server.js -type file -force
New-Item config.js -type file -force
New-Item .gitignore -type file -force
New-Item .babelrc -type file -force
New-Item .jshint -type file -force
cd server
New-Item controllers -type directory -force
New-Item models -type directory -force
cd ../front
New-Item src -type directory -force
New-Item dist -type directory -force
New-Item index.html -type file -force
cd src
New-Item css -type directory -force
New-Item js -type directory -force
cd js
New-Item index.js -type file -force
cd ../css
New-Item common.css -type file -force
New-Item normalize.css -type file -force
cd ../../..
Remove-Item startScript.ps1







