require 'rails_helper'

if RUBY_VERSION>='2.6.0'
  if Rails.version < '5'
    class ActionController::TestResponse < ActionDispatch::TestResponse
      def recycle!
        @mon_mutex_owner_object_id = nil
        @mon_mutex = nil
        initialize
      end
    end
  else
    puts "Monkeypatch for ActionController::TestResponse no longer needed"
  end
end

describe MoviesController do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end
    
    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).with(hash_including('title' => 'hardware')).
        and_return(@fake_results)
      get :search_tmdb, { title: 'hardware', commit: 'Search' }
    end

    describe 'after valid search' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb).with(any_args).and_return(@fake_results)
        get :search_tmdb, { title: 'hardware', commit: 'Search' }
      end
      
      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end

      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end
  end
  
  describe 'adding a movie from TMDb' do
    it 'calls the create method and redirects to the search page' do
      expect(Movie).to receive(:create!).with(
        'title' => 'Inception',
        'rating' => 'PG-13',
        'release_date' => '2010-07-16',
        'description' => 'A thief who steals corporate secrets.'
      ).and_return(double('Movie', title: 'Inception'))

      post :add_movie, {
        title: 'Inception',
        rating: 'PG-13',
        release_date: '2010-07-16',
        description: 'A thief who steals corporate secrets.'
      }
      
      expect(flash[:success]).to eq "Inception was successfully added to RottenPotatoes."
      expect(response).to redirect_to(search_tmdb_path)
    end
  end
end