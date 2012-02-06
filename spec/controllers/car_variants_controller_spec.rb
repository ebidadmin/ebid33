require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe CarVariantsController do

  # This should return the minimal set of attributes required to create a valid
  # CarVariant. As you add validations to CarVariant, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end
  
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CarVariantsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all car_variants as @car_variants" do
      car_variant = CarVariant.create! valid_attributes
      get :index, {}, valid_session
      assigns(:car_variants).should eq([car_variant])
    end
  end

  describe "GET show" do
    it "assigns the requested car_variant as @car_variant" do
      car_variant = CarVariant.create! valid_attributes
      get :show, {:id => car_variant.to_param}, valid_session
      assigns(:car_variant).should eq(car_variant)
    end
  end

  describe "GET new" do
    it "assigns a new car_variant as @car_variant" do
      get :new, {}, valid_session
      assigns(:car_variant).should be_a_new(CarVariant)
    end
  end

  describe "GET edit" do
    it "assigns the requested car_variant as @car_variant" do
      car_variant = CarVariant.create! valid_attributes
      get :edit, {:id => car_variant.to_param}, valid_session
      assigns(:car_variant).should eq(car_variant)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new CarVariant" do
        expect {
          post :create, {:car_variant => valid_attributes}, valid_session
        }.to change(CarVariant, :count).by(1)
      end

      it "assigns a newly created car_variant as @car_variant" do
        post :create, {:car_variant => valid_attributes}, valid_session
        assigns(:car_variant).should be_a(CarVariant)
        assigns(:car_variant).should be_persisted
      end

      it "redirects to the created car_variant" do
        post :create, {:car_variant => valid_attributes}, valid_session
        response.should redirect_to(CarVariant.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved car_variant as @car_variant" do
        # Trigger the behavior that occurs when invalid params are submitted
        CarVariant.any_instance.stub(:save).and_return(false)
        post :create, {:car_variant => {}}, valid_session
        assigns(:car_variant).should be_a_new(CarVariant)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        CarVariant.any_instance.stub(:save).and_return(false)
        post :create, {:car_variant => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested car_variant" do
        car_variant = CarVariant.create! valid_attributes
        # Assuming there are no other car_variants in the database, this
        # specifies that the CarVariant created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        CarVariant.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => car_variant.to_param, :car_variant => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested car_variant as @car_variant" do
        car_variant = CarVariant.create! valid_attributes
        put :update, {:id => car_variant.to_param, :car_variant => valid_attributes}, valid_session
        assigns(:car_variant).should eq(car_variant)
      end

      it "redirects to the car_variant" do
        car_variant = CarVariant.create! valid_attributes
        put :update, {:id => car_variant.to_param, :car_variant => valid_attributes}, valid_session
        response.should redirect_to(car_variant)
      end
    end

    describe "with invalid params" do
      it "assigns the car_variant as @car_variant" do
        car_variant = CarVariant.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        CarVariant.any_instance.stub(:save).and_return(false)
        put :update, {:id => car_variant.to_param, :car_variant => {}}, valid_session
        assigns(:car_variant).should eq(car_variant)
      end

      it "re-renders the 'edit' template" do
        car_variant = CarVariant.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        CarVariant.any_instance.stub(:save).and_return(false)
        put :update, {:id => car_variant.to_param, :car_variant => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested car_variant" do
      car_variant = CarVariant.create! valid_attributes
      expect {
        delete :destroy, {:id => car_variant.to_param}, valid_session
      }.to change(CarVariant, :count).by(-1)
    end

    it "redirects to the car_variants list" do
      car_variant = CarVariant.create! valid_attributes
      delete :destroy, {:id => car_variant.to_param}, valid_session
      response.should redirect_to(car_variants_url)
    end
  end

end