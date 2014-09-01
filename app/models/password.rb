require 'digest'

class Password

  def self.create_hash(password)
    password.blank? ? nil : Digest::SHA2.hexdigest(password + 'o@98d!jj&6n')
  end

end
