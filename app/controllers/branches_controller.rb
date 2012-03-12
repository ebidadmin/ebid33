class BranchesController < ApplicationController
  before_filter :check_admin_role
  layout 'layout2'
  
  def index
    @branches = Branch.includes(:company, :city, :approver)
  end

  def show
    @branch = Branch.find(params[:id])
  end

  def new
    store_location
    @branch = Branch.new
  end

  def create
    @branch = Branch.new(params[:branch])
    if @branch.save
      # redirect_to @branch, :notice => "Successfully created branch."
      redirect_back_or_default(branches_path)
    else
      render :action => 'new'
    end
  end

  def edit
    # store_location
    @branch = Branch.find(params[:id])
  end

  def update
    @branch = Branch.find(params[:id])
    if @branch.update_attributes(params[:branch])
      redirect_to branches_path, :notice  => "Successfully updated branch."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @branch = Branch.find(params[:id])
    @branch.destroy
    redirect_to branches_url, :notice => "Successfully destroyed branch."
  end
end
