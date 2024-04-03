class AuthorsController < ApplicationController
  before_action :set_author, only: [:show, :edit, :update, :destroy]

  class AuthorsSearch < FortyFacets::FacetSearch
    model 'Author' # which model to search for
    text  :last_name # filter by a generic string entered by the user
    #scope :isap # to select only authors that approve sharing their data
    facet :given_name, name: 'Given Name'
    facet :last_name, name: 'Last Name'

    orders 'Name (A-Z)' => {last_name: :asc, given_name: :asc},
           'Name (Z-A)' => {last_name: :desc, given_name: :desc},
           'ORCID (A-Z)' => "orcid asc",
           'ORCID (Z-A)' => {orcid: :desc}
  end
  
  # GET /authors or /authors.json
  def index
    @search = AuthorsSearch.new(params)# initializes search object from request params
    @authors = @search.result.isap.paginate(:page => params[:page], :per_page => 10)
  end

  # GET /authors/1 or /authors/1.json
  def show
  end

  # GET /authors/new
  def new
    @author = Author.new
  end

  # GET /authors/1/edit
  def edit
  end

  # POST /authors or /authors.json
  def create
    @author = Author.new(author_params)

    respond_to do |format|
      if @author.save
        format.html { redirect_to author_url(@author), notice: "Author was successfully created." }
        format.json { render :show, status: :created, location: @author }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /authors/1 or /authors/1.json
  def update
    respond_to do |format|
      if @author.update(author_params)
        format.html { redirect_to author_url(@author), notice: "Author was successfully updated." }
        format.json { render :show, status: :ok, location: @author }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authors/1 or /authors/1.json
  def destroy
    @author.destroy!

    respond_to do |format|
      format.html { redirect_to authors_url, notice: "Author was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_author
      @author = Author.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def author_params
      params.require(:author).permit(:last_name, :given_name, :orcid, :isap)
    end
end
