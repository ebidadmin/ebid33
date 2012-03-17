class CompaniesController < ApplicationController
  before_filter :check_admin_role, except: :selected
  layout 'layout2'
  
  def index
    @companies = Company.all
  end

  def show
    @company = Company.find(params[:id])
    @friends = @company.friends
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(params[:company])
    if @company.save
      redirect_to @company, :notice => "Successfully created company."
    else
      render :action => 'new'
    end
  end

  def edit
    store_location
    @company = Company.find(params[:id])
  end

  def update
    @company = Company.find(params[:id])
    if @company.update_attributes(params[:company])
      redirect_back_or_default(companies_path)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @company = Company.find(params[:id])
    @company.destroy
    redirect_to companies_url, :notice => "Successfully destroyed company."
  end
  
  def selected
    @branches = Branch.where(company_id: params[:id]).order(:name)
    render :partial => 'companies/selected'
  end
  
end
