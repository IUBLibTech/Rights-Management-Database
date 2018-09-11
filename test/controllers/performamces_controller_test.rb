require 'test_helper'

class PerformamcesControllerTest < ActionController::TestCase
  setup do
    @performamce = performamces(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:performances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create performamce" do
    assert_difference('Performance.count') do
      post :create, performamce: {  }
    end

    assert_redirected_to performamce_path(assigns(:performamce))
  end

  test "should show performamce" do
    get :show, id: @performamce
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @performamce
    assert_response :success
  end

  test "should update performamce" do
    patch :update, id: @performamce, performamce: {  }
    assert_redirected_to performamce_path(assigns(:performamce))
  end

  test "should destroy performamce" do
    assert_difference('Performance.count', -1) do
      delete :destroy, id: @performamce
    end

    assert_redirected_to performamces_path
  end
end
