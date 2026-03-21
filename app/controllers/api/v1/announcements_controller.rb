class Api::V1::AnnouncementsController < Api::V1::ApplicationController
  before_action :set_announcement, only: %i[ show update destroy send_announcement stats delivery_logs]

  # GET /api/v1/announcements
  def index
    announcements = @current_school.announcements
                                    .order(created_at: :desc)
                                    .page(params[:page])
                                    .per(params[:per_page] || 20)

    render json: {
      data: JSON.parse(AnnouncementSerializer.render(announcements)),
      meta: pagination_meta(announcements)
    }
  end

  # GET /api/v1/announcements/1
  def show
    render json: AnnouncementSerializer.render(@announcement, view: :with_stats)
  end

  # POST /api/v1/announcements
  def create
    result = AnnouncementCreator.call(
      school: @current_school,
      params: announcement_params
    )

    if result.success?
      render json: AnnouncementSerializer.render(result.announcement), status: :created
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/announcements/1
  def update
    unless @announcement.draft?
      render json: { error: "Só é possível editar comunicados em rascunho" }, status: :unprocessable_entity
      return
    end
    
    if @announcement.update(announcement_params)
      render json: AnnouncementSerializer.render(@announcement)
    else
      render json: { errors: @announcement.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/announcements/1
  def destroy
    @announcement.destroy!
    head :no_content
  end

  # POST /api/v1/announcements/:id/send
  def send_announcement
    result = AnnouncementSender.call(@announcement)

    if result.success?
      render json: AnnouncementSerializer.render(@announcement.reload), status: :accepted
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/announcements/:id/stats
  def stats
    render json: AnnouncementStatsQuery.call(@announcement)
  end

  # GET /api/v1/announcements/:id/delivery_logs
  def delivery_logs
    logs = @announcement.delivery_logs
                        .includes(:guardian)
                        .limit(10)

    render json: logs.as_json(
      only: [:id, :read, :read_at],
      include: { guardian: { only: [:id, :name, :email] } }
    )
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_announcement
    @announcement = @current_school.announcements.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def announcement_params
    params.require(:announcement).permit(
      :title, :content, :attachment_url, :scope,
      classroom_ids: [],
      student_ids:   []
    )
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      total_pages:  collection.total_pages,
      total_count:  collection.total_count,
      per_page:     collection.limit_value
    }
  end
end
