require 'prawn/labels'

class Group < ActiveRecord::Base
  LABELS_PATH = '/tmp'
  LABELS_FILE = 'mailing_labels.pdf'

  has_and_belongs_to_many :addresses

  before_destroy :clear_address_associations

  validates_presence_of :name

  def self.find_for_list
    Group.order('name')
  end

  def addresses_not_included
    included_ids = self.address_ids
    if included_ids.blank?
      Address.eligible_for_group
    else
      Address.eligible_for_group.where(['id not in (?)', included_ids])
    end
  end

  def create_labels(label_type)
    Prawn::Labels.render(self.addresses, :type => label_type) do |pdf, a|
      label_text =  a.addressee + "\n"
      label_text += a.address1 + "\n"
      label_text += a.address2 + "\n" unless a.address2.blank?
      label_text += a.city + ', ' + a.state + ' ' + a.zip

      pdf.text label_text
    end
  end

  private

    def clear_address_associations
      addresses.clear
    end

end
