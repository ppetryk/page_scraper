require "test_helper"

class Api::HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get data" do
    get api_home_data_url
    assert_response :success
  end
end
