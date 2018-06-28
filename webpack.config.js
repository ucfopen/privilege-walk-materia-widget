const path = require('path')

let srcPath = path.join(process.cwd(), 'src')
let outputPath = path.join(process.cwd(), 'build')

// load the reusable legacy webpack config from materia-widget-dev
let webpackConfig = require('materia-widget-development-kit/webpack-widget').getLegacyWidgetBuildConfig({
	//pass in extra files for webpack to copy
	preCopy: [
		{
			from: srcPath+'/angular-sortable-view.min.js',
			to: outputPath,
		},
	]
})

webpackConfig.entry['scorescreen.js'] = [path.join(__dirname, 'src', 'scorescreen.coffee')]
webpackConfig.entry['scorescreen.css'] = [
	path.join(__dirname, 'src', 'scorescreen.html'),
	path.join(__dirname, 'src', 'scorescreen.scss')
]

module.exports = webpackConfig
