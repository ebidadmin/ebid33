class BranchesController < ApplicationController
  def index
    @branches = Branch.all
  end

  def show
    @branch = Branch.find(params[:id])
  end

  def new
    @branch = Branch.new
  end

  def create
    @branch = Branch.new(params[:branch])
    if @branch.save
      redirect_to @branch, :notice => "Successfully created branch."
    else
      render :action => 'new'
    end
  end

  def edit
    @branch = Branch.find(params[:id])
  end

  def update
    @branch = Branch.find(params[:id])
    if @branch.update_attributes(params[:branch])
      redirect_to @branch, :notice  => "Successfully updated branch."
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
