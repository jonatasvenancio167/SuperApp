class DeliveryLogsController < ApplicationController
  before_action :set_delivery_log, only: %i[ show update destroy ]

  # GET /delivery_logs
  def index
    @delivery_logs = DeliveryLog.all

    render json: @delivery_logs
  end

  # GET /delivery_logs/1
  def show
    render json: @delivery_log
  end

  # POST /delivery_logs
  def create
    @delivery_log = DeliveryLog.new(delivery_log_params)

    if @delivery_log.save
      render json: @delivery_log, status: :created, location: @delivery_log
    else
      render json: @delivery_log.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /delivery_logs/1
  def update
    if @delivery_log.update(delivery_log_params)
      render json: @delivery_log
    else
      render json: @delivery_log.errors, status: :unprocessable_content
    end
  end

  # DELETE /delivery_logs/1
  def destroy
    @delivery_log.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery_log
      @delivery_log = DeliveryLog.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def delivery_log_params
      params.require(:delivery_log).permit(:announcement_id, :guardian_id, :read, :read_at)
    end
end
