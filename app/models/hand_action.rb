class HandAction < ActiveRecord::Base
  belongs_to :hand
  belongs_to :player
end
