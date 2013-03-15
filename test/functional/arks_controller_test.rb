require 'test_helper'

class ArksControllerTest < ActionController::TestCase
  setup do
    @ark = arks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:arks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ark" do
    assert_difference('Ark.count') do
      post :create, ark: { namespace_ark: @ark.namespace_ark, namespace_id: @ark.namespace_id, noid: @ark.noid, pid: @ark.pid, url_base: @ark.url_base, view_object: @ark.view_object, view_thumbnail: @ark.view_thumbnail }
    end

    assert_redirected_to ark_path(assigns(:ark))
  end

  test "should show ark" do
    get :show, id: @ark
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ark
    assert_response :success
  end

  test "should update ark" do
    put :update, id: @ark, ark: { namespace_ark: @ark.namespace_ark, namespace_id: @ark.namespace_id, noid: @ark.noid, pid: @ark.pid, url_base: @ark.url_base, view_object: @ark.view_object, view_thumbnail: @ark.view_thumbnail }
    assert_redirected_to ark_path(assigns(:ark))
  end

  test "should destroy ark" do
    assert_difference('Ark.count', -1) do
      delete :destroy, id: @ark
    end

    assert_redirected_to arks_path
  end
end
