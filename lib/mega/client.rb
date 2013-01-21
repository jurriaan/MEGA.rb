module MEGA
  class Client
    def initialize(user, password)
      @user = user
      @password_key = MEGA::Crypto.prepare_key_pw(password)
      @user_hash = MEGA::Crypto.stringhash(@user,@password_key)
    end
    
    def get_sid
      request = Request.new(a: 'us', user: @user, uh: @user_hash)
      response = request.run
    end
  end
end