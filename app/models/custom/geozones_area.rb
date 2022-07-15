class GeozonesArea < ActiveRecord::Base
  belongs_to :geozone
  has_many :users
end
