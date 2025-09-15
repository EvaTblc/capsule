require "date"

class BookItem < Item
  before_create :publishing_date

  def publishing_date
    date_str = metadata["published_date"].presence
      return unless date_str

    if date_str.include?("-")
      self.released_on = Date.strptime(date_str, "%Y-%m-%d") rescue nil
    else
      self.released_on = Date.new(date_str.to_i, 1, 1) rescue nil
    end
  end

  def isbn_13
    metadata["isbn_13"]
  end
end
