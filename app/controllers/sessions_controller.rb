class SessionsController < Devise::SessionsController
  skip_before_filter :authenticate_user!, unless: :devise_controller?

  # GET /resource/sign_in
  def new
    # resource = build_resource
    # clean_up_passwords(resource)
    # respond_with_navigational(resource, stub_options(resource)){ render_with_scope :new }
    render layout: 'layout2'
  end

end
