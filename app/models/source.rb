class Source < ApplicationRecord
  validates_uniqueness_of :filename
  before_validation :no_path_in_filename

  def no_path_in_filename()
    self.filename = self.filename.split('/').last
  end
end
