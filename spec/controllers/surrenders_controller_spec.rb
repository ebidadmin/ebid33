require File.dirname(__FILE__) + '/../spec_helper'

describe SurrendersController do
  fixtures :all
  render_views

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    get :show, :id => Surrender.first
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Surrender.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Surrender.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(surrender_url(assigns[:surrender]))
  end

  it "edit action should render edit template" do
    get :edit, :id => Surrender.first
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    Surrender.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Surrender.first
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    Surrender.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Surrender.first
    response.should redirect_to(surrender_url(assigns[:surrender]))
  end

  it "destroy action should destroy model and redirect to index action" do
    surrender = Surrender.first
    delete :destroy, :id => surrender
    response.should redirect_to(surrenders_url)
    Surrender.exists?(surrender.id).should be_false
  end
end
