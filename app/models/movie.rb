class Movie < ActiveRecord::Base
  def self.find_in_tmdb(search_params, api_key = '031cf0ed8d1e80fcb253105cb20c7598')
    search_query = search_params[:title] || search_params[:search_terms]
    
    return nil if search_query.blank?

    url = "https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{URI.encode_www_form_component(search_query)}"
    
    url += "&year=#{search_params[:release_year]}" unless search_params[:release_year].blank?
    url += "&language=#{search_params[:language]}" unless search_params[:language].blank?

    response = Faraday.get(url)
    data = JSON.parse(response.body)

    return [] if data["results"].blank?

    data["results"].map do |movie|
      Movie.new(
        title: movie["title"],
        release_date: movie["release_date"],
        rating: "R",
        description: movie["overview"]
      )
    end
  end

  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil? || ratings.empty?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end
end