require "erubis"
require "rulers/file_model"

module Rulers
	class Controller
		include Rulers::Model
		
		def initialize(env)
			@env = env
			@routing_params = {}
		end

		def env
			@env
		end

		def dispatch(action, routing_params = {})
			@routing_params = routing_params
			text = self.send(action)
			r = get_response
			if r
				[r.status, r.headers, [r.body].flatten]
			else
				[200, {'Content-Type' => 'text/html'}, [text].flatten]
			end
		end

		# Creates and sets the response on the controller
		def response(text, status=200, headers={})
			raise "Already responded" if @response
			a = [text].flatten
			@response = Rack::Response.new(a, status, headers)
		end

		# Returns the set response (only for library use)
		def get_response
			@response
		end
		
		def render(view_name)
			filename = File.join("app", "views", controller_name, "#{view_name}.html.erb")
			template = File.read(filename)
			eruby = Erubis::Eruby.new(template)
			# Make the controllers instance variables available in the view
			self.instance_variables.each { |var|
				val = self.instance_variable_get(var)
				eruby.instance_variable_set(var, val)
			}
			compiled_view = eruby.result :env => env
			response(compiled_view)
		end

		def controller_name
			klass = self.class
			klass = klass.to_s.gsub(/Controller$/, "")
			Rulers.to_underscore(klass)
		end

		def request
			@request ||= Rack::Request.new(@env)
		end

		def params
			request.params.merge @routing_params
		end

		def self.action(action, routing_params= {})
			proc { |e| self.new(e).dispatch(action, routing_params) }
		end
	end
end