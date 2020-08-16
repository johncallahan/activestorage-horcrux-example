class UploadsController < ApplicationController
  before_action :set_upload, only: [:show, :edit, :update, :destroy]

  # GET /uploads
  # GET /uploads.json
  def index
    @uploads = Upload.all
  end

  # GET /uploads/1
  # GET /uploads/1.json
  def show
    @secret = ""
    begin
      @secret = @upload.clip.download
    rescue TSS::ArgumentError
      @secret = "[error: NOT ENOUNG SHARES]"
    rescue ParamContractError
      @secret = "[error: INVALID KEY(S)]"
    rescue Lockbox::DecryptionError
      @secret = "[error: CANNOT DECRYPT]"
    end
  end

  # GET /uploads/new
  def new
    @upload = Upload.new
  end

  # GET /uploads/1/edit
  def edit
    @secret = ""
    begin
      @secret = @upload.clip.download
    rescue TSS::ArgumentError
      @secret = "NOT ENOUNG SHARES"
    rescue ParamContractError
      @secret = "INVALID KEY(S)"
    end
  end

  # POST /uploads
  # POST /uploads.json
  def create
    @upload = Upload.new(upload_params)

    ok = true
    begin
      @upload.save
    rescue ParamContractError
      ok = false
      @upload.delete
    end

    respond_to do |format|
      if ok
        filename = Dir.glob("/tmp/" + @upload.clip.blob.key + "*")[0]
        file = File.open(filename)
	keys = file.read
	file.close
	File.delete(filename)
	@upload.clip.blob.key = keys
	@upload.clip.blob.save!

        format.html { redirect_to @upload, notice: 'Upload was successfully created.' }
        format.json { render :show, status: :created, location: @upload }
      else
        format.html { redirect_to uploads_path, notice: 'Upload was too large' }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /uploads/1
  # PATCH/PUT /uploads/1.json
  def update
    respond_to do |format|
      if updatekey
        format.html { redirect_to @upload, notice: 'Upload was successfully updated.' }
        format.json { render :show, status: :ok, location: @upload }
      else
        format.html { render :edit }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /uploads/1
  # DELETE /uploads/1.json
  def destroy
    @upload.destroy
    respond_to do |format|
      format.html { redirect_to uploads_url, notice: 'Upload was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def updatekey
      @upload.clip.blob.key = params[:name].join(',')
      @upload.clip.blob.save!
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_upload
      @upload = Upload.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def upload_params
      params.require(:upload).permit(:clip,:name)
    end
end
