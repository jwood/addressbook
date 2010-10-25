require 'digest'

class Password

  def self.encode(password)
    Digest::SHA2.hexdigest(password + 'o@98d!jj&6n')
  end

end
