class RandomMemeBroker
  require 'http'

  def GetRandomMeme
    memesResponse = HTTP.get("http://api.imgflip.com/get_memes")
    memes = memesResponse.parse
    return memes["data"]["memes"][0]["url"]
  end

end
