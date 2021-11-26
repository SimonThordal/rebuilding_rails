require "rulers/version"
require "rulers/array"
require "rulers/routing"
require "rulers/util"
require "rulers/dependencies"
require "rulers/controller"
require "rulers/file_model"
require "rulers/sqlite_model"

module Rulers
  class Error < StandardError; end
  
  class Application
    def return_404 body="Resource not found"
      [404, {"Content-Type" => 'text/html'}, [body]]
    end

    def return_500 body="An internal server error occurred"
      [500, {'Content-Type' => 'text/html'}, [body]]
    end

    def return_200 body
      [200, {'Content-Type' => 'text/html'}, [body]]
    end

    def return_301 url
      message = "This content was permanently moved to #{url}"
      response_headers = {
        'Content-Type' => 'text/html',
        'Location' => url
      }
      [301, response_headers, [message]]
    end

  	def call(env)
      begin
        if env["PATH_INFO"] === "/favicon.ico" 
    			return self.return_404
        else
          rack_app = get_rack_app(env)
          rack_app.call(env)
        end
      rescue Exception => e
        log_line = "ERROR: " + e.message
        %x{echo #{log_line} >> debug.log }
        # Return the result of the controller action
        raise e
      end 
  	end
  end
end

