module MainHelper

  def chunk_list(object_list)
    chunks = {}
    ('A'..'Z').each { |letter| chunks[letter] = [] }

    if object_list.try(:first).class == Contact
      object_list.each { |contact| chunks[contact.last_name[0].chr.upcase] << contact }
    elsif object_list.try(:first).class == Address
      object_list.each do |address|
        first_letter = address.addressee_for_display[0].chr.upcase
        chunks[first_letter] << address unless chunks[first_letter].nil?
      end
    end

    chunks.sort
  end

end
