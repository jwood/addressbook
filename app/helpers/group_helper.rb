module GroupHelper

  def get_label_options(label_types)
    label_options = "" 
    label_types.each { |label_type| label_options << "<option>#{label_type}</option>" }
    label_options
  end

end
