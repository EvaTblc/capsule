require "date"

class BookItem < Item
  before_create :publishing_date

  def publishing_date
    if self.metadata["published_date"].chars.include?("-")
      self.released_on = Date.strptime(self.metadata["published_date"])
    else
      self.released_on = DateTime.new(self.metadata["published_date"].to_i, 1, 1)
    end
  end

  def isbn_13
    metadata["isbn_13"]
  end
end
