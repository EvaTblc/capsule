require "open-uri"
require "json"

class ItemsController < ApplicationController
  before_action :set_item, except: [ :index, :scan, :intake, :new, :create ]
  before_action :set_collection_category, only: [ :scan, :intake, :new, :create ]

  def index
    @collection = Collection.find(params[:collection_id])
    @category = Category.find(params[:category_id])
    @items = Item.where(collection: @collection, category: @category)
    @item = Item.new

    # Rediriger vers scan si la catégorie est vide et supporte le scan
    scannable_categories = ["Livre", "Jeux Vidéo", "Film"]
    if @category.items.empty? && scannable_categories.include?(@category.name)
      redirect_to scan_collection_category_items_path(@collection, @category)
    end
  end
  def show
    @collection = Collection.find(params[:collection_id])
    @category = Category.find(params[:category_id])
    @item = Item.find(params[:id])
    @collection = Collection.find(params[:collection_id])
    @tags = ItemsTag.where(item: @item)
  end

  def edit
    @collection = Collection.find(params[:collection_id])
    @category   = Category.find(params[:category_id])

    @item.items_tags.build if @item.items_tags.empty?
  end

  def update
    @collection = Collection.find(params[:collection_id])
    @category   = @collection.categories.find(params[:category_id])
    @item       = @category.items.find(params[:id])

    attrs = item_params.dup
    files = attrs.delete(:photos) # idem : on enlève du hash

    if @item.update(attrs)
      @item.photos.attach(files.reject(&:blank?)) if files.present?
      redirect_to collection_category_item_path(@collection, @category, @item)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def scan
  end

  # Recherche IGDB par nom (pour AJAX)
  def search_game
    query = params[:query].to_s.strip
    return render json: { error: "Query vide" }, status: :unprocessable_entity if query.blank?

    token = IgdbService.access_token
    return render json: { error: "Token IGDB indisponible" }, status: :service_unavailable unless token

    response = HTTParty.post(
      "https://api.igdb.com/v4/games",
      headers: {
        'Client-ID' => ENV['IGDB_CLIENT_ID'],
        'Authorization' => "Bearer #{token}"
      },
      body: "fields name,cover.url,platforms.name,summary,genres.name,first_release_date; search \"#{query}\"; where platforms = (130); limit 10;"
    )

    if response.code == 200 && response.parsed_response.any?
      games = response.parsed_response.map do |game|
        {
          id: game['id'],
          name: game['name'],
          cover_url: game.dig('cover', 'url') ? "https:#{game['cover']['url'].gsub('t_thumb', 't_thumb')}" : nil,
          platforms: game['platforms']&.map { |p| p['name'] }&.join(', '),
          release_date: game['first_release_date'] ? Time.at(game['first_release_date']).year : nil
        }
      end
      render json: { games: games }
    else
      render json: { games: [] }
    end
  rescue => e
    Rails.logger.error("[search_game] Erreur: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def intake
    barcode = params[:barcode].presence || params.dig(:item, :barcode).to_s
    barcode = barcode.strip
    status = params[:status].presence || "owned"
    return render(json: { error: "Barcode manquant" }, status: :unprocessable_entity) if barcode.blank?

    # Déterminer le type d'item basé sur la catégorie et le barcode
    klass = determine_item_type(barcode)

    item = klass.find_or_initialize_by(
      collection_id: @collection.id,
      category_id:   @category.id,
      barcode:       barcode
    )

    if item.new_record?
      begin
        enrich_item_from_api(item)
      rescue => e
        Rails.logger.warn("[intake] enrichment failed: #{e.class} #{e.message}")
      end
      item.name ||= "Nouvel objet"
    end

    payload = {
      name: item.name,
      barcode: item.barcode,
      type: klass.name,
      source: item.source,
      source_id: item.source_id,
      status: status,
      metadata: item.metadata.presence || {}
    }

    Rails.logger.debug("[intake] item après enrichment: #{item.inspect}")

    if request.format.json?
      render json: payload, status: :ok
    else
      prefill = Base64.strict_encode64(payload.to_json)
      redirect_to new_collection_category_item_path(@collection, @category, prefill: prefill)
    end
  end

  def new
    @collection = Collection.find(params[:collection_id])
    @category   = @collection.categories.find(params[:category_id])

    prefill = {}
    if params[:prefill].present?
      prefill = JSON.parse(Base64.decode64(params[:prefill])) rescue {}
    end

    @item = @category.items.build(
      name:      prefill["name"],
      barcode:   prefill["barcode"],
      type:      prefill["type"],
      source:    prefill["source"],
      source_id: prefill["source_id"],
      metadata:  prefill["metadata"] || {}
    )
  end

  def create
    attrs = item_params.dup
    files = attrs.delete(:photos) # on sort les fichiers du hash

    # Déterminer le bon type d'item
    item_type = attrs[:type].present? ? attrs[:type] : 'Item'
    klass = item_type.constantize

    @item = klass.new(attrs)
    @item.category = @category
    @item.collection = @collection

    if @item.save
      @item.photos.attach(files.reject(&:blank?)) if files.present?

      # Télécharger la cover IGDB si disponible dans les metadata
      if @item.metadata["cover_url"].present? && @item.photos.count == 0
        download_and_attach_cover(@item, @item.metadata["cover_url"])
      end

      redirect_to collection_category_item_path(@collection, @category, @item)
    else
      render :new, status: :unprocessable_entity
    end
  end


  def destroy
    if @item.destroy
      redirect_to  collection_category_items_path
    else
      render :show, status: :see_other
    end
  end

  private

  def set_collection_category
    @collection = Collection.find(params[:collection_id])
    @category = Category.find(params[:category_id])
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    p = params.require(:item).permit(:name, :possession, :state, :type, :barcode, :source, :source_id, :price, :status,
      metadata: {},
      photos: [],
      item_copies_attributes: [ :id, :state, :price, :purchase_date, :notes, :_destroy ])
    p[:metadata] = JSON.parse(p[:metadata]) rescue {} if p[:metadata].is_a?(String)
    p
  end

  # Détermine le type d'item basé sur la catégorie et le barcode
  def determine_item_type(barcode)
    case @category.name
    when "Livre"
      BookItem
    when "Jeux Vidéo"
      VideoGameItem
    when "Film"
      MovieItem
    when "Figurine"
      ToyItem
    else
      # Fallback: essayer de deviner par le barcode (ISBN pour livres)
      if barcode.start_with?("978", "979") && barcode.length == 13
        BookItem
      else
        Item
      end
    end
  end

  # Méthode générique qui délègue à la méthode d'enrichissement appropriée
  def enrich_item_from_api(item)
    case item.class.name
    when "BookItem"
      api_book_item(item)
    when "VideoGameItem"
      api_video_game_item(item)
    when "MovieItem"
      api_movie_item(item)
    when "ToyItem"
      api_toy_item(item)
    end
  end

  # Enrichissement pour les livres (code existant conservé)
  def api_book_item(item)
    url = "https://www.googleapis.com/books/v1/volumes?q=isbn:#{item.barcode}"
    item_serialized = URI.parse(url).read
    data = JSON.parse(item_serialized)

    volume  = data.dig("items", 0) || {}
    info    = volume["volumeInfo"] || {}
    snippet = volume.dig("searchInfo", "textSnippet")

    return if info.blank?

    item.name = info["title"]

    item.metadata = {
      isbn_13:        item.barcode,
      authors:        info["authors"],       # peut être nil si absent
      publisher:      info["publisher"],
      published_date: info["publishedDate"],
      language:       info["language"],
      description:    info["description"] || snippet
    }.compact  # enlève juste les nil
    item.raw = volume
  end

  # Enrichissement pour les jeux vidéo (UPCitemdb → IGDB)
  def api_video_game_item(item)
    # Étape 1 : Récupérer le nom du jeu via UPCitemdb
    product_name = fetch_product_name_from_upc(item.barcode)

    if product_name
      Rails.logger.info("[api_video_game_item] Produit trouvé via UPCitemdb: #{product_name}")
      # Étape 2 : Chercher dans IGDB avec le nom
      search_igdb_by_name(item, product_name)
    else
      # Fallback : chercher directement dans IGDB avec des mots-clés communs
      Rails.logger.info("[api_video_game_item] Fallback: recherche IGDB directe")
      search_igdb_fallback(item)
    end
  end

  # Enrichissement pour les films (à implémenter avec une API)
  def api_movie_item(item)
    # TODO: Implémenter l'enrichissement via API (ex: TMDB, OMDb, etc.)
    Rails.logger.info("[api_movie_item] Enrichissement non implémenté pour #{item.barcode}")
  end

  # Enrichissement pour les figurines (à implémenter avec une API si disponible)
  def api_toy_item(item)
    # TODO: Implémenter l'enrichissement si API disponible
    Rails.logger.info("[api_toy_item] Enrichissement non implémenté pour #{item.barcode}")
  end

  # Récupère le nom du produit via UPCitemdb (gratuit, illimité)
  def fetch_product_name_from_upc(barcode)
    response = HTTParty.get(
      "https://api.upcitemdb.com/prod/trial/lookup",
      query: { upc: barcode }
    )

    if response.code == 200 && response.dig('items', 0)
      product = response['items'][0]
      title = product['title']

      # Nettoyer le titre pour avoir juste le nom du jeu
      # Ex: "The Legend of Zelda Breath of the Wild - Nintendo Switch" → "The Legend of Zelda Breath of the Wild"
      clean_title = clean_game_title(title)

      Rails.logger.info("[UPCitemdb] Produit trouvé: #{title} → Nettoyé: #{clean_title}")
      return clean_title
    end

    Rails.logger.warn("[UPCitemdb] Aucun produit trouvé pour le barcode #{barcode}")
    nil
  rescue => e
    Rails.logger.error("[UPCitemdb] Erreur: #{e.message}")
    nil
  end

  # Nettoie le titre du jeu en retirant les mentions de plateforme
  def clean_game_title(title)
    # Retirer les mentions de plateforme courantes
    platforms = [
      "Nintendo Switch", "PlayStation 5", "PS5", "PlayStation 4", "PS4",
      "Xbox Series X", "Xbox One", "PC", "Steam", "Nintendo 3DS", "Wii U"
    ]

    clean = title
    platforms.each do |platform|
      clean = clean.gsub(/\s*-\s*#{platform}/i, '')
      clean = clean.gsub(/\s*\(#{platform}\)/i, '')
      clean = clean.gsub(/\s*\[#{platform}\]/i, '')
    end

    clean.strip
  end

  # Recherche dans IGDB par nom de jeu
  def search_igdb_by_name(item, game_name)
    token = IgdbService.access_token
    return unless token

    response = HTTParty.post(
      "https://api.igdb.com/v4/games",
      headers: {
        'Client-ID' => ENV['IGDB_CLIENT_ID'],
        'Authorization' => "Bearer #{token}"
      },
      body: "fields name,cover.url,platforms.name,summary,genres.name,first_release_date; search \"#{game_name}\"; limit 1;"
    )

    if response.code == 200 && response.parsed_response.any?
      game = response.parsed_response.first
      populate_item_from_igdb(item, game)
      Rails.logger.info("[IGDB] Jeu enrichi: #{item.name}")
    else
      Rails.logger.warn("[IGDB] Aucun jeu trouvé pour '#{game_name}'")
    end
  rescue => e
    Rails.logger.error("[IGDB] Erreur: #{e.message}")
  end

  # Recherche IGDB en fallback : laisse l'item vide pour saisie manuelle
  # L'utilisateur pourra saisir le nom manuellement dans le formulaire
  def search_igdb_fallback(item)
    # On ne fait rien ici, l'item restera avec name = "Nouvel objet"
    # et l'utilisateur pourra saisir le nom manuellement
    # Une amélioration future serait d'offrir une recherche interactive
    Rails.logger.info("[IGDB Fallback] Aucune donnée trouvée, saisie manuelle requise")
  end

  # Remplit un item avec les données IGDB (code commun)
  def populate_item_from_igdb(item, game)
    item.name = game['name']
    item.source = 'igdb'
    item.source_id = game['id'].to_s

    # Convertir la date de release (timestamp Unix)
    release_date = nil
    if game['first_release_date']
      release_date = Time.at(game['first_release_date']).to_date rescue nil
    end

    # Récupérer l'URL de la cover
    cover_url = game.dig('cover', 'url') ? "https:#{game['cover']['url'].gsub('t_thumb', 't_cover_big')}" : nil

    # Traduire le summary en français si présent
    summary = game['summary']
    if summary.present?
      summary = translate_to_french(summary)
    end

    item.metadata = {
      platforms: game['platforms']&.map { |p| p['name'] }&.join(', '),
      summary: summary,
      cover_url: cover_url,
      genres: game['genres']&.map { |g| g['name'] }&.join(', '),
      release_date: release_date&.to_s
    }.compact

    item.raw = game

    # Télécharger et attacher la cover comme photo
    if cover_url.present?
      download_and_attach_cover(item, cover_url)
    end
  end

  # Télécharge et attache la cover IGDB comme photo de l'item
  def download_and_attach_cover(item, cover_url)
    require 'open-uri'

    # Télécharger l'image
    downloaded_image = URI.open(cover_url)

    # Générer un nom de fichier
    filename = "#{item.name.parameterize}-cover.jpg"

    # Attacher l'image à l'item
    item.photos.attach(
      io: downloaded_image,
      filename: filename,
      content_type: 'image/jpeg'
    )

    Rails.logger.info("[IGDB] Cover téléchargée et attachée: #{filename}")
  rescue => e
    Rails.logger.error("[IGDB] Erreur lors du téléchargement de la cover: #{e.message}")
  end

  # Traduit un texte en français via LibreTranslate
  def translate_to_french(text)
    return text if text.blank?

    response = HTTParty.post(
      "https://libretranslate.com/translate",
      body: {
        q: text,
        source: "en",
        target: "fr",
        format: "text"
      }.to_json,
      headers: {
        'Content-Type' => 'application/json'
      },
      timeout: 10
    )

    if response.code == 200 && response.parsed_response['translatedText'].present?
      translated = response.parsed_response['translatedText']
      Rails.logger.info("[LibreTranslate] Texte traduit avec succès")
      translated
    else
      Rails.logger.warn("[LibreTranslate] Traduction échouée, texte original conservé")
      text
    end
  rescue => e
    Rails.logger.error("[LibreTranslate] Erreur: #{e.message}")
    text  # Retourner le texte original en cas d'erreur
  end
end
