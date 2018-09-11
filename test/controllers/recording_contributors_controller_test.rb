require 'test_helper'

class RecordingContributorsControllerTest < ActionController::TestCase
  setup do
    @recording_contributor = recording_contributors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:recording_contributors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create recording_contributor" do
    assert_difference('RecordingContributor.count') do
      post :create, recording_contributor: {  }
    end

    assert_redirected_to recording_contributor_path(assigns(:recording_contributor))
  end

  test "should show recording_contributor" do
    get :show, id: @recording_contributor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @recording_contributor
    assert_response :success
  end

  test "should update recording_contributor" do
    patch :update, id: @recording_contributor, recording_contributor: {  }
    assert_redirected_to recording_contributor_path(assigns(:recording_contributor))
  end

  test "should destroy recording_contributor" do
    assert_difference('RecordingContributor.count', -1) do
      delete :destroy, id: @recording_contributor
    end

    assert_redirected_to recording_contributors_path
  end
end
