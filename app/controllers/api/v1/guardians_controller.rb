class Api::V1::GuardiansController < Api::V1::ApplicationController
  before_action :set_guardian, only: %i[ show update destroy ]

  # GET /guardians
  def index
    @guardians = Guardian.all

    render json: @guardians
  end

  # GET /guardians/1
  def show
    render json: @guardian
  end

  # POST /guardians
  def create
    @guardian = Guardian.new(guardian_params)

    if @guardian.save
      render json: @guardian, status: :created, location: @guardian
    else
      render json: @guardian.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /guardians/1
  def update
    if @guardian.update(guardian_params)
      render json: @guardian
    else
      render json: @guardian.errors, status: :unprocessable_content
    end
  end

  # DELETE /guardians/1
  def destroy
    @guardian.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_guardian
      @guardian = Guardian.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def guardian_params
      params.require(:guardian).permit(:name, :email)
    end
end
