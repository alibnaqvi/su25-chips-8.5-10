Rottenpotatoes::Application.routes.draw do
  # map '/' to be a redirect to '/movies'
  get 'movies/search_tmdb', to: 'movies#search_tmdb', as: 'search_tmdb'
  post '/add_movie', to: 'movies#add_movie', as: 'add_movie'

  resources :movies

  root to: redirect('/movies')
end