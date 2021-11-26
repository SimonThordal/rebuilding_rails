require "test_helper"
require "rulers/sqlite_model"

class RulersTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rulers::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
