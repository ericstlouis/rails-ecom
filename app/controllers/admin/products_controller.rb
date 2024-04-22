class Admin::ProductsController < AdminController
  before_action :set_admin_product, only: %i[ show edit update destroy ]

  # GET /admin/products or /admin/products.json
  def index
    # if query is  present in url search for product
    if params[:query].present?
      @pagy, @admin_products = pagy(Product.where("name LIKE ?", "%#{params[:query]}%"))
    else
      # if query is not present show all products
       @pagy, @admin_products = pagy(Product.all)
    end
  end

  # GET /admin/products/1 or /admin/products/1.json
  def show
  end

  # GET /admin/products/new
  def new
    @admin_product = Product.new
  end

  # GET /admin/products/1/edit
  def edit
  end

  # POST /admin/products or /admin/products.json
  def create
    @admin_product = Product.new(admin_product_params)

    respond_to do |format|
      if @admin_product.save
        format.html { redirect_to admin_product_url(@admin_product), notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @admin_product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @admin_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/products/1 or /admin/products/1.json
  # the reason why we have to make the update fucntion is because the
  # admin_product_params(which is prvate function look at the bottom code)
  # has an empty array at the end that overwrites the prevouis code
  def update
    # fetch the product using the id from the params hash aka the url
    @admin_product = Product.find(params[:id])
    # updating all the non images attributes but using reject function to filter out the images attribute using a key value pair
    # the key is ["images"]
    # so basically this updates all the text fields but not images fields
    if @admin_product.update(admin_product_params.reject { |k| k["images"] })
    # check to see if the user did send images
      if admin_product_params["images"]
    # if the uder did sends images it will loop over all of them and attach them to the admin
      # product using the attach method
        admin_product_params["images"].each do |image|
          @admin_product.images.attach(image)
        end

        # redirects to admin product page after a sucessful update
      end
      redirect_to admin_products_path, notice: "Product updated successfully"
      # if the update fails show the edit page with errors
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/products/1 or /admin/products/1.json
  def destroy
    @admin_product.destroy!

    respond_to do |format|
      format.html { redirect_to admin_products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_product
      @admin_product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def admin_product_params
      params.require(:product).permit(:name, :description, :price, :category_id, :active, images: [])
    end
end
