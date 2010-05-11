require 'pdf/label'

class Group < ActiveRecord::Base
  LABELS_PATH = File::join RAILS_ROOT, "public"
  LABELS_FILE = "mailing_labels.pdf"

  has_and_belongs_to_many :addresses

  validates_presence_of :name

  def self.find_for_list
    Group.find(:all, :order => 'name')
  end

  def addresses_not_included
    Address.eligible_for_group.find(:all, :conditions => ['id not in (?)', self.address_ids])
  end

  def create_labels(label_type)
    p = Pdf::Label::Batch.new(label_type.sub(' ', '  '))

    pos = 0
    self.addresses.each do |a|
      label_text =  a.addressee + "\n"
      label_text += a.address1 + "\n"
      label_text += a.address2 + "\n" unless a.address2.blank?
      label_text += a.city + ", " + a.state + " " + a.zip
      p.add_label(:text => label_text,
                  :position => pos,
                  :font_size => 10,
                  :justification => :center)
      pos = pos.next
    end

    p.save_as("#{LABELS_PATH}/#{LABELS_FILE}")
  end

end
