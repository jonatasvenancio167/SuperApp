class Api::V1::SchoolsController < Api::V1::ApplicationController
  before_action :set_school, only: %i[ show update destroy ]

  # GET api/v1/schools
  def index
    @schools = School.all

    render json: @schools
  end

  # GET api/v1/schools/1
  def show
    render json: @school
  end

  # POST api/v1/schools
  def create
    @school = School.new(school_params)

    if @school.save
      render json: @school, status: :created, location: @school
    else
      render json: @school.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT api/v1/schools/1
  def update
    if @school.update(school_params)
      render json: @school
    else
      render json: @school.errors, status: :unprocessable_content
    end
  end

  # DELETE api/v1/schools/1
  def destroy
    @school.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_school
      @school = School.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def school_params
      params.require(:school).permit(:name, :code)
    end
end
