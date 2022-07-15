class AddGeozoneToGeozonesAreas < ActiveRecord::Migration[5.2]
  def change
    add_reference :geozones_areas, :geozone, foreign_key: true
  end
end
