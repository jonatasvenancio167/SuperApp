require "test_helper"

class ClassroomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @classroom = classrooms(:one)
  end

  test "should get index" do
    get classrooms_url, as: :json
    assert_response :success
  end

  test "should create classroom" do
    assert_difference("Classroom.count") do
      post classrooms_url, params: { classroom: { grade: @classroom.grade, name: @classroom.name, school_id: @classroom.school_id } }, as: :json
    end

    assert_response :created
  end

  test "should show classroom" do
    get classroom_url(@classroom), as: :json
    assert_response :success
  end

  test "should update classroom" do
    patch classroom_url(@classroom), params: { classroom: { grade: @classroom.grade, name: @classroom.name, school_id: @classroom.school_id } }, as: :json
    assert_response :success
  end

  test "should destroy classroom" do
    assert_difference("Classroom.count", -1) do
      delete classroom_url(@classroom), as: :json
    end

    assert_response :no_content
  end
end
