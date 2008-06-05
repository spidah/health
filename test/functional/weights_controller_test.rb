require File.dirname(__FILE__) + '/../test_helper'
require 'weights_controller'

# Re-raise errors caught by the controller.
class WeightsController; def rescue_action(e) raise e end; end

class WeightsControllerTest < Test::Unit::TestCase
  def setup
    @controller = WeightsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
