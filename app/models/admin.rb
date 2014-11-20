# encoding: utf-8
class Admin < ActiveRecord::Base

  validates_presence_of :username

  # validates_uniqueness_of :email, :allow_blank => false, :if => :email_required?, :on => :create

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  attr_accessible :email, :password, :password_confirmation, :username, :role
  validates_presence_of :password, :on => :create
  validates_presence_of :password_confirmation, :on => :create

  def role_name
    if self.role == 1
      "管理员"
    elsif self.role == 2
      "录入人员"
    end
  end
end
