class Phone

  def self.sanitize(phone_number)
    return nil if phone_number.nil?

    sanitized_phone_number = phone_number.gsub(/[a-zA-Z\-.()+,\s]/, '')

    if sanitized_phone_number[0,1] == '1'
      sanitized_phone_number = sanitized_phone_number[1, sanitized_phone_number.size]
    end

    sanitized_phone_number
  end

  def self.valid?(phone_number)
    return false if phone_number.blank?
    return false if self.sanitize(phone_number).size != 10
    return true
  end

  def self.format(phone_number)
    if Phone.valid?(phone_number)
      phone_number = Phone.sanitize(phone_number)
      "#{phone_number[0..2]}-#{phone_number[3..5]}-#{phone_number[6..9]}"
    else
      phone_number
    end
  end

end
