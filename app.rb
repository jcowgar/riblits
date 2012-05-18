# encoding: utf-8
require 'sinatra'
require 'haml'
require 'log4r'

LOGGER = Log4r::Logger.new 'myapp'
LOGGER.outputters = [
  Log4r::RollingFileOutputter.new('myapp', :filename => './amifit_log.log', :max => 5242880)
]

L = LOGGER

require_relative 'minify_resources'

class MyApp < Sinatra::Application
	enable :sessions

	configure :production do
    LOGGER.level = Log4r::WARN

		set :haml, { :ugly => true }
		set :clean_trace, true
		set :css_files, :blob
		set :js_files,  :blob
		
		MinifyResources.minify_all
		
		$DBURL = 'postgres://user@localhost/myapp'
	end

	configure :development do |c|
    LOGGER.outputters << Log4r::Outputter.stdout

    require 'sinatra/reloader'
    c.also_reload "helpers/*.rb"
    c.also_reload "modules/*.rb"
    c.also_reload "routes/*.rb"
    
		set :css_files, MinifyResources::CSS_FILES
		set :js_files,  MinifyResources::JS_FILES
		
		$DBURL = 'postgres://user@localhost/myapp_dev'
	end

	helpers do
		include Rack::Utils
		alias_method :h, :escape_html
	end
end

require_relative 'helpers/init'
require_relative 'models/init'
require_relative 'routes/init'
