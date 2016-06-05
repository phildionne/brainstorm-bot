class RandomMemeBroker
  require 'http'

  def GetRandomMeme
    memesResponse = HTTP.get("http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC")
    memesJson = memesResponse.parse
    meme = memesJson["data"]["url"]
    return meme
  end

end
