module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user_id, :nickname

    def connect
      uuid = SecureRandom.uuid
      self.user_id = "user_#{uuid}"
      self.nickname = cookies.signed['nickname']
    end
  end
end
