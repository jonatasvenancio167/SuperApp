require "test_helper"

class DeliveryLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @delivery_log = delivery_logs(:one)
  end

  test "should get index" do
    get delivery_logs_url, as: :json
    assert_response :success
  end

  test "should create delivery_log" do
    assert_difference("DeliveryLog.count") do
      post delivery_logs_url, params: { delivery_log: { announcement_id: @delivery_log.announcement_id, guardian_id: @delivery_log.guardian_id, read: @delivery_log.read, read_at: @delivery_log.read_at } }, as: :json
    end

    assert_response :created
  end

  test "should show delivery_log" do
    get delivery_log_url(@delivery_log), as: :json
    assert_response :success
  end

  test "should update delivery_log" do
    patch delivery_log_url(@delivery_log), params: { delivery_log: { announcement_id: @delivery_log.announcement_id, guardian_id: @delivery_log.guardian_id, read: @delivery_log.read, read_at: @delivery_log.read_at } }, as: :json
    assert_response :success
  end

  test "should destroy delivery_log" do
    assert_difference("DeliveryLog.count", -1) do
      delete delivery_log_url(@delivery_log), as: :json
    end

    assert_response :no_content
  end
end
