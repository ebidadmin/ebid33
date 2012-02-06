class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable
  devise :encryptable, :encryptor => :authlogic_sha512

  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :opt_in, 
    :profile_attributes

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile, allow_destroy: true, reject_if: proc { |obj| obj.blank? }
  has_one :company, through: :profile
  has_one :branch, through: :profile
  has_and_belongs_to_many :roles
  
  has_one :cart, dependent: :destroy, include: [:cart_items => :car_part]
  has_many :entries, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_one :seller, through: :order
  has_many :messages, dependent: :destroy
  has_many :receivers, through: :messages
  has_many :buyers, through: :fees
  has_many :sellers, through: :fees
  
  delegate :address1, :address2, :city_name, to: :branch, allow_nil:true
  delegate :phone, :fax, :birthdate, to: :profile
  delegate :nickname, to: :company
  
  # default_scope #includes(:profile => [:company, :branch])
  # default_scope  includes(:roles)
  
  validates_presence_of :username, :email
  validates_presence_of [:password, :password_confirmation], :if => :password_required?
  
  def password_required? 
    encrypted_password.blank? || !password.blank?
  end

  def role?(role)
    return !!self.roles.find_by_name(role.to_s)
  end
  
end
