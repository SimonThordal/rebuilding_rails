require './config/application'

app = BestQuotes::Application.new

use Rack::ContentType

app.route do
	match '', 'quotes#index'
	root 'quotes#index'
	match "sub-app",
		proc { [200, {}, ['Hello, sub-app!']] }
	match ':controller/:id/:action'
	match ':controller/create', default: {'action' => 'create'}
	match ':controller/:id', default: {'action' => 'show'}
	match ':controller', default: {'action' => 'index'}
end

run app