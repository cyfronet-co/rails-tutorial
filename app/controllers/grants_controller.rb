class GrantsController < ApplicationController
  before_action :set_grant, only: %i[ show edit update destroy ]

  # GET /grants or /grants.json
  def index
    @grants = Grant.all
  end

  # GET /grants/1 or /grants/1.json
  def show
  end

  # GET /grants/new
  def new
    @grant = Grant.new
  end

  # GET /grants/1/edit
  def edit
  end

  # POST /grants or /grants.json
  def create
    @grant = Grant.new(grant_params)

    respond_to do |format|
      if @grant.save
        format.html { redirect_to @grant, notice: "Grant was successfully created." }
        format.json { render :show, status: :created, location: @grant }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @grant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /grants/1 or /grants/1.json
  def update
    respond_to do |format|
      if @grant.update(grant_params)
        format.html { redirect_to @grant, notice: "Grant was successfully updated." }
        format.json { render :show, status: :ok, location: @grant }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @grant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grants/1 or /grants/1.json
  def destroy
    @grant.destroy
    respond_to do |format|
      format.html { redirect_to grants_url, notice: "Grant was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grant
      @grant = Grant.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def grant_params
      params.require(:grant).permit(:title, :name, :content, documents: [])
    end
end
