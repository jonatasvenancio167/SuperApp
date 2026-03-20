class Api::V1::DeliveryLogsController < Api::V1::ApplicationController
  # POST /api/v1/delivery_logs/:id/read
  def read
    log = DeliveryLog.find(params[:id])

    if log.read?
      render json: {
        message: "Comunicado já havia sido marcado como lido",
        read_at: log.read_at
      }
      return
    end

    log.mark_as_read!

    render json: {
      message: "Comunicado marcado como lido",
      read_at: log.read_at
    }
  end
end
