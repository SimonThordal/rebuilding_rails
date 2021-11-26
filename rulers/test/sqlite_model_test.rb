require_relative "test_helper"
require "rulers/sqlite_model"

class TestModel < Rulers::Model::SQLiteModel;
end

class SQLiteModelTest < Minitest::Test
	def setup
		@title_var = "This is a model"
	end
	
	def test_that_attributes_can_be_accessed_with_dots
		model = TestModel.new("title" => @title_var)
		assert_equal @title_var, model.title 
	end

	def test_that_it_sets_instance_method_for_accessor
		model = TestModel.new("title" => @title_var)
		assert model.respond_to?(:title)
	end
	

end
