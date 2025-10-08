class IgdbService
  CACHE_KEY = "igdb_access_token"

  def self.access_token
    token = Rails.cache.read(CACHE_KEY)
    if token.nil?
      token = fetch_new_token
      Rails.cache.write(CACHE_KEY, token, expires_in: 59.days)
    end
    token
  end

  private

  def self.fetch_new_token
    response = HTTParty.post(
      "https://id.twitch.tv/oauth2/token",
      query: {
        client_id: ENV['IGDB_CLIENT_ID'],
        client_secret: ENV['IGDB_CLIENT_SECRET'],
        grant_type: 'client_credentials'
      }
    )
    response.parsed_response['access_token']
  rescue => e
    Rails.logger.error("IGDB token fetch failed: #{e.message}")
    nil
  end
end
