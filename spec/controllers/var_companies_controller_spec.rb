require File.dirname(__FILE__) + '/../spec_helper'

describe VarCompaniesController do
  fixtures :all
  render_views

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    get :show, :id => VarCompany.first
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    VarCompany.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    VarCompany.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(var_company_url(assigns[:var_company]))
  end

  it "edit action should render edit template" do
    get :edit, :id => VarCompany.first
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    VarCompany.any_instance.stubs(:valid?).returns(false)
    put :update, :id => VarCompany.first
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    VarCompany.any_instance.stubs(:valid?).returns(true)
    put :update, :id => VarCompany.first
    response.should redirect_to(var_company_url(assigns[:var_company]))
  end

  it "destroy action should destroy model and redirect to index action" do
    var_company = VarCompany.first
    delete :destroy, :id => var_company
    response.should redirect_to(var_companies_url)
    VarCompany.exists?(var_company.id).should be_false
  end
end
