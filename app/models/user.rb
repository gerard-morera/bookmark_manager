class User

  require 'bcrypt'
  include DataMapper::Resource

  attr_reader   :password
  attr_accessor :password_confirmation

  validates_confirmation_of :password, :message => "Password and confirmation password do not match"
  validates_uniqueness_of   :email,    :message => "Email taken"  
  validates_presence_of     :password, :message => "Password required"
  validates_presence_of     :email,    :message => "Email required"

  property :email,            String, required: true, :unique => true
  property :id,               Serial
  property :password_digest,  Text

  #go at some point to database and check password_digest

  def password= password
    @password = password

    self.password_digest = BCrypt::Password.create password
  end

  def self.authenticate email, password
    user = User.first(email: email)

    if user && BCrypt::Password.new(user.password_digest) == password 
      user
    else
      nil
    end
  end

end
