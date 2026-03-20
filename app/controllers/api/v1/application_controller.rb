class Api::V1::ApplicationController < ActionController::API
  before_action :set_current_school

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid,  with: :unprocessable_entity

  private

  def set_current_school
    school_id = request.headers["X-School-Id"]

    if school_id.blank?
      render json: { error: "X-School-Id header é obrigatório" }, status: :unauthorized and return
    end

    @current_school = School.find(school_id)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Escola não encontrada" }, status: :unauthorized
  end

  def not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end
end
