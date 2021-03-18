class AuthorsController < ApplicationController
  before_action :set_author, only: [:show, :edit, :update, :destroy]

  class AuthorsSearch < FortyFacets::FacetSearch
    model 'Author' # which model to search for
    text  :last_name # filter by a generic string entered by the user
    #scope :isap # to select only authors that approve sharing their data
    facet :given_name, name: 'Given Name'
    facet :last_name, name: 'Last Name'

    orders 'Last name, Ascendign' => {last_name: :asc, given_name: :asc},
           'Last name, descending' => "last_name desc",
           'ORCID, ascending' => "orcid asc",
           'ORCID, Descending' => {orcid: :desc}
  end


  # GET /authors
  # GET /authors.json
  def index
    #@authors = Author.all
    print(params["search"])
    @search = AuthorsSearch.new(params)# initializes search object from request params
    @authors = @search.result.isap.paginate(:page => params[:page], :per_page => 10)
  end

  # GET /authors/1
  # GET /authors/1.json
  def show
  end

  # GET /authors/new
  def new
    @author = Author.new()
    @article_author = nil
    # if parameters are given, prepopulate object
    if params.include?('given_name')
      @author.given_name = params["given_name"]
      @author.last_name = params["last_name"]
      @author.orcid = params["orcid"]
      if params["art_aut_id"] != nil
        @article_author = ArticleAuthor.find(params["art_aut_id"])
      end
    end
  end

  # GET /authors/1/edit
  def edit
  end

  # POST /authors
  # POST /authors.json
  def create
    @author = Author.new(author_params)
    respond_to do |format|
      @author.full_name = @author.last_name + ", " + @author.given_name
      if @author.save
        format.html { redirect_to @author, notice: 'Author was successfully created.' }
        format.json { render :show, status: :created, location: @author }
      else
        format.html { render :new }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /authors/1
  # PATCH/PUT /authors/1.json
  def update
    # use a temporary parameter array to store params and modify if needed
    temp_params = author_params
    puts "params last_name: " + temp_params['last_name']
    if temp_params['last_name'] != nil and temp_params['last_name'] != ""
      temp_params['full_name'] = temp_params['last_name'] + ", " +
        temp_params['given_name']
    else
      temp_params['full_name'] = temp_params['given_name']
    end
    @author.full_name = @author.last_name + ", " + @author.given_name
    respond_to do |format|
      if @author.update(temp_params)
        format.html { redirect_to @author, notice: 'Author was successfully updated.' }
        format.json { render :show, status: :ok, location: @author }
      else
        format.html { render :edit }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authors/1
  # DELETE /authors/1.json
  def destroy
    @author.destroy
    respond_to do |format|
      format.html { redirect_to authors_url, notice: 'Author was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # generate affilitions from CR records
  def generate
    GenerateAffiliationsCrossrefWorker.perform_async
    respond_to do |format|
      flash[:notice] = 'Affiliation generation process started'
      format.html { redirect_to action: "index" }
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
      params.require(:author).permit(:full_name, :last_name, :given_name, :orcid, :articles)
    end
end
