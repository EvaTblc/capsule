module ItemsHelper
  CURRENCY_SYMBOL = {
    "EUR" => "€", "USD" => "$", "GBP" => "£", "JPY" => "¥", "CHF" => "CHF",
    "CAD" => "$", "AUD" => "$"
  }.freeze

  LANGUAGE_NAMES = {
    "fr" => "Français",
    "en" => "Anglais",
    "us" => "Anglais",
    "es" => "Espagnol",
    "de" => "Allemand",
    "it" => "Italien",
    "ja" => "Japonais",
    "zh" => "Chinois",
    "ru" => "Russe"
    # ➕ tu complètes au besoin
  }.freeze

  def format_language(code)
    return "" if code.blank?
    LANGUAGE_NAMES[code.downcase] || code
  end

  def display_currency(code)
    CURRENCY_SYMBOL[code.to_s.upcase] || code
  end

  def format_price_with_currency(price, currency)
    return "" if price.blank?
    unit = display_currency(currency)
  end
end
