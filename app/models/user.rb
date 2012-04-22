class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :nickname

  validates :nickname, :length => {:minimum => 3, :maximum => 20}, :uniqueness => true

  has_many :players
  has_many :games, :through => :players, :order => "winning_player_id"

  has_many :map_votes

  has_many :maps, :dependent => :destroy

  has_many :notifications, :dependent => :destroy
end
