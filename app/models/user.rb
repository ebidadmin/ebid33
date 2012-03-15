class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable
  devise :encryptable, :encryptor => :authlogic_sha512

  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :opt_in, 
    :profile_attributes, :role_ids

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile, allow_destroy: true, reject_if: proc { |obj| obj.blank? }
  has_one :company, through: :profile
  has_one :branch, through: :profile
  has_and_belongs_to_many :roles
  accepts_nested_attributes_for :roles, allow_destroy: true, reject_if: proc { |obj| obj.blank? }
  
  has_one :cart, dependent: :destroy, include: [:cart_items => :car_part]
  has_many :entries, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :sellers, through: :orders
  has_many :messages, dependent: :destroy
  has_many :receivers, through: :messages
  has_many :buyers, through: :fees
  has_many :sellers, through: :fees
  has_many :variances, dependent: :destroy
  has_one :approver, through: :branch
  has_many :car_variants
  has_many :creators, through: :car_variants
  has_many :cities
  # has_many :creators, through: :car_parts
  
  delegate :address1, :address2, :city_name, to: :branch, allow_nil:true
  delegate :first_name, :shortname, :phone, :fax, :birthdate, :rank_name, to: :profile, allow_nil:true
  delegate :nickname, to: :company
  
  # default_scope #includes(:profile => [:company, :branch])
  # default_scope  includes(:roles)
  scope :opt_in, where(opt_in: true)
  
  validates_presence_of :username, :email
  validates_uniqueness_of :username, :email
  validates_presence_of [:password, :password_confirmation], :if => :password_required?
  validates_associated :profile
  
  def password_required? 
    encrypted_password.blank? || !password.blank?
  end

  def role?(role)
    return !!self.roles.find_by_name(role.to_s)
  end
  
end
