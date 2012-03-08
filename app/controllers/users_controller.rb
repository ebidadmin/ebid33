class UsersController < ApplicationController
  # load_and_authorize_resource
  before_filter :check_admin_role, only: [:index, :destroy]
  
  def index
    @users = User.includes(:profile, :company, :roles).order('updated_at DESC').paginate(page: params[:page], per_page: 20)
  end

  def show
    if current_user.role?(:admin)
      @user = User.find(params[:id])
    else
      @user = current_user
    end
    @profile = @user.profile
    @all_roles = Role.all
  end

  def new
    @user = User.new
    @user.build_profile
    @company_type = Role.find(2, 3)
    @branches = []
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to root_path, :notice => "Account created. Please wait for E-Bid to authorize your account."
    else
      @user.build_profile
      @company_type = Role.find(2, 3)
      @branches = []
      flash[:error] = "Please complete the required info."
      render :action => 'new'
    end
  end

  def edit
    store_location
    if current_user.role?('admin')
      @user = User.find(params[:id])
      @company_type = Role.find(1, 2, 3)
    else
      @user = current_user
      @company_type = Role.find(2, 3)
    end
    @branches = Branch.where(company_id: @user.company.id)
  end

  def update
    if current_user.role?('admin')
      @user = User.find(params[:id])
      @company_type = Role.find(1, 2, 3)
    else
      @user = current_user
      @company_type = Role.find(2, 3)
    end
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated user."
      redirect_back_or_default :back #redirect_to @user
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_url, :notice => "Successfully destroyed user."
  end
end
