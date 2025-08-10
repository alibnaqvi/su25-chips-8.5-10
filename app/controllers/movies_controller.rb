class MoviesController < ApplicationController
  before_action :force_index_redirect, only: [:index]

  def show
    id = params[:id]
    @movie = Movie.find(id)
  end

  def index
    @all_ratings = Movie.all_ratings
    @movies = Movie.with_ratings(ratings_list, sort_by)
    @ratings_to_show_hash = ratings_hash
    @sort_by = sort_by
    session['ratings'] = ratings_list
    session['sort_by'] = @sort_by
  end

  def new
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  def search_tmdb
    if params[:commit] 
      if params[:title].blank?
        flash.now[:warning] = "Please fill in all required fields!"
      else
        @movies = Movie.find_in_tmdb(params)
        if @movies.blank?
          flash.now[:warning] = 'No movies found with given parameters!'
        end
      end
    end
    render :search_tmdb
  end

  def add_movie
    movie = Movie.create!(add_movie_params)
    flash[:success] = "#{movie.title} was successfully added to RottenPotatoes."
    redirect_to search_tmdb_path
  end

  private

  def movie_params
    params.require(:movie).permit(:title, :rating, :release_date, :description)
  end

  def add_movie_params
    params.permit(:title, :release_date, :rating, :description)
  end

  def force_index_redirect
    return unless !params.key?(:ratings) || !params.key?(:sort_by)
    flash.keep
    url = movies_path(sort_by: sort_by, ratings: ratings_hash)
    redirect_to url
  end

  def ratings_list
    params[:ratings]&.keys || session[:ratings] || Movie.all_ratings
  end

  def ratings_hash
    ratings_list.to_h { |item| [item, "1"] }
  end

  def sort_by
    params[:sort_by] || session[:sort_by] || 'id'
  end
end
