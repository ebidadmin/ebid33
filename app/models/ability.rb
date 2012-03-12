class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new 
    if user.role?(:admin)
      can :access, :all
    elsif user.role?(:powerbuyer)
      # can :access, :all
      can :access, :entries
      can :accept, :bids
      can [:create, :update, :read, :print, :change_status, :cancel, :confirm_cancel, :change_status], :orders
      can [:read, :create, :update], :users, id: user.id
      can [:read], [:branches, :companies]
      can :access, [:car_brands, :car_models, :car_variants, :regions]
      can :create, :car_variant
    elsif user.role?(:buyer)
      can :access, :home, :cart
      can :access, :users, id: user.id
      cannot :search, :users
      can [:create, :update, :put_online, :relist], :entries
      can :accept, :bids
      can [:create, :update, :read, :print, :change_status, :cancel, :confirm_cancel, :change_status], :orders, user_id: user.id
      can :access, [:car_brands, :car_models, :car_variants, :regions]
      can :access, :messages, user_id: user.id
      can :read, :fees
      can :create, :car_variant
    elsif user.role?(:seller)
      can :access, [:home, :bids]
      can :read, :entries
      can [:read, :accept, :change_status], :orders
      can :confirm_payment, :orders
      can :access, :messages
      can :access, :users, id: user.id
    else
      can :access, :home
      can :create, [:users, :profiles, :companies, :branches]
      can :read, [:users, :profiles, :companies, :branches]
    end
    
    # The first argument to `can` is the action the user can perform. The second argument
    # is the controller name they can perform that action on. You can pass :access and :all
    # to represent any action and controller respectively. Passing an array to either of
    # these will grant permission on each item in the array.
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
