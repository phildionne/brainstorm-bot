class RandomMemeBroker
  require 'http'

  def GetRandomMeme
    memesResponse = HTTP.get("http://api.imgflip.com/get_memes")
    memesJson = memesResponse.parse
    memes = memesJson["data"]["memes"]
    return memes[1 + Random.rand(memes.length)]["url"]
  end

end
