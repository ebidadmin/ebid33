class VarCompaniesController < ApplicationController
  def index
    @var_companies = VarCompany.all
  end

  def show
    @var_company = VarCompany.find(params[:id])
  end

  def new
    @var_company = VarCompany.new
  end

  def create
    @var_company = VarCompany.new(params[:var_company])
    if @var_company.save
      redirect_to @var_company, :notice => "Successfully created var company."
    else
      render :action => 'new'
    end
  end

  def edit
    @var_company = VarCompany.find(params[:id])
  end

  def update
    @var_company = VarCompany.find(params[:id])
    if @var_company.update_attributes(params[:var_company])
      redirect_to @var_company, :notice  => "Successfully updated var company."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @var_company = VarCompany.find(params[:id])
    @var_company.destroy
    redirect_to var_companies_url, :notice => "Successfully destroyed var company."
  end
end
