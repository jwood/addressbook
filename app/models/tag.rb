class Tag < ActiveRecord::Base
  include ActiveModel::Validations
  validates :icon, url: { schemes: ['http', 'https'] }
end
