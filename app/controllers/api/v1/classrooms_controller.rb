class Api::V1::ClassroomsController < Api::V1::ApplicationController
  before_action :set_classroom, only: %i[ show update destroy ]

  # GET api/v1/classrooms
  def index
    @classrooms = Classroom.all

    render json: @classrooms
  end

  # GET api/v1/classrooms/1
  def show
    render json: @classroom
  end

  # POST api/v1/classrooms
  def create
    @classroom = Classroom.new(classroom_params)

    if @classroom.save
      render json: @classroom, status: :created
    else
      render json: @classroom.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT api/v1/classrooms/1
  def update
    if @classroom.update(classroom_params)
      render json: @classroom
    else
      render json: @classroom.errors, status: :unprocessable_content
    end
  end

  # DELETE api/v1/classrooms/1
  def destroy
    @classroom.destroy!
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_classroom
      @classroom = Classroom.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def classroom_params
      params.require(:classroom).permit(:school_id, :name, :grade)
    end
end
