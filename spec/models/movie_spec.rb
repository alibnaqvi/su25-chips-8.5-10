require 'rails_helper'
require 'webmock/rspec'

describe Movie do
  describe 'searching Tmdb by keyword' do
    let(:fake_results) { {"results"=>[{"title"=>"Movie1", "release_date"=>"2022-01-01", "overview"=>"Overview1"}, {"title"=>"Movie2", "release_date"=>"2021-01-01", "overview"=>"Overview2"}]} }
    
    before(:each) do
      stub_request(:get, /api.themoviedb.org/).
        to_return(status: 200, body: fake_results.to_json, headers: {})
    end

    it 'calls Faraday with the correct query parameters' do
      expect(Faraday).to receive(:get).with(a_string_matching(/query=hacker/)).and_call_original
      Movie.find_in_tmdb({title: "hacker", language: "en"})
    end

    it 'returns an array of Movie objects' do
      movies = Movie.find_in_tmdb({title: "some_movie"})
      expect(movies).to all(be_a(Movie))
      expect(movies.first.title).to eq("Movie1")
    end
    
    it 'returns an empty array if no results are found' do
      stub_request(:get, /api.themoviedb.org/).
        to_return(status: 200, body: '{"results":[]}', headers: {})
      movies = Movie.find_in_tmdb({title: "nonexistent"})
      expect(movies).to eq([])
    end
    
    it 'returns nil if the title parameter is blank' do
      expect(Movie.find_in_tmdb({title: ""})).to be_nil
    end
  end
end
