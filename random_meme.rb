module RandomMeme
  require 'http'

  def get_url
    memesResponse = HTTP.get("http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC")
    memes = JSON.parse(memesResponse)
    memes["data"]["fixed_height_downsampled_url"]
  end
  module_function :get_url
end
