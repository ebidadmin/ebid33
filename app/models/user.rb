class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable
  devise :encryptable, :encryptor => :authlogic_sha512

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile, allow_destroy: true, reject_if: proc { |obj| obj.blank? }
  has_one :company, through: :profile
  has_one :branch, through: :profile
  has_and_belongs_to_many :roles
  
  has_one :cart, dependent: :destroy
  has_many :entries, dependent: :destroy
  has_many :bids, dependent: :destroy
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email#, :password, :password_confirmation, :remember_me
end
