require 'httparty'
require 'base64'
require 'crack'
require "erb"

class SimpleNote
  include HTTParty
  attr_reader :token, :email
  base_uri 'https://simple-note.appspot.com/api'

  def login(email, password)
    encoded_body = Base64.encode64({:email => email, :password => password}.to_params)
    @email = email
    @token = self.class.post "/login", :body => encoded_body
  end

  def get_index
    self.class.get "/index", :query => request_hash, :format => :json
  end

  def get_note(key)
    self.class.get "/note", :query => request_hash.merge(:key => key)
  end

  def delete_note(key)
    self.class.get "/delete", :query => request_hash.merge(:key => key)
  end

  def search(search_string, max_results=10)
    self.class.get "/search", :query => request_hash.merge(:query => search_string, :results => max_results)
  end

  def create_note(note)
    self.class.post("/note", 
      :query => request_hash.merge(:modify => ERB::Util.url_encode(Time.now.strftime("%Y-%m-%d %H:%M:%S"))), 
      :body => Base64.encode64(note))
  end
    
  def update_note(key, note)
    self.class.post("/note", 
      :query => request_hash.merge(
                  :modify => ERB::Util.url_encode(Time.now.strftime("%Y-%m-%d %H:%M:%S")),
                  :key => key), 
      :body => Base64.encode64(note))
  end

  private

  def request_hash
    { :auth => token, :email => email }
  end
end
