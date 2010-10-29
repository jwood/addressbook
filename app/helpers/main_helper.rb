module MainHelper

  def chunk_contact_list(contact_list)
    chunks = {}
    ('A'..'Z').each { |letter| chunks[letter] = [] }
    contact_list.each { |contact| chunks[contact.last_name[0].chr.upcase] << contact }
    chunks.sort
  end

end
