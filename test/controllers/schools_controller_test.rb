require "test_helper"

class SchoolsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @school = schools(:one)
  end

  test "should get index" do
    get schools_url, as: :json
    assert_response :success
  end

  test "should create school" do
    assert_difference("School.count") do
      post schools_url, params: { school: { code: @school.code, name: @school.name } }, as: :json
    end

    assert_response :created
  end

  test "should show school" do
    get school_url(@school), as: :json
    assert_response :success
  end

  test "should update school" do
    patch school_url(@school), params: { school: { code: @school.code, name: @school.name } }, as: :json
    assert_response :success
  end

  test "should destroy school" do
    assert_difference("School.count", -1) do
      delete school_url(@school), as: :json
    end

    assert_response :no_content
  end
end
