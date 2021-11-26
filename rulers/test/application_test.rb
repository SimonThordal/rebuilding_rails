require_relative "test_helper"

class TestApp < Rulers::Application
end

class TestController < Rulers::Controller
	def show
		"Hello"
	end
end

class RulersAppTest < Minitest::Test
	include Rack::Test::Methods

	def app
		TestApp.new
	end

	def test_request
		get "/test/show"
		assert last_response.ok?
		body = last_response.body
		assert body["Hello"]
	end
	
end