class RandomImageBroker
  require './RandomWordBroker.rb'

  BASE_URL = "http://loremflickr.com/320/240/"

  def GetRandomImageUrl
    randomWordBroker = RandomWordBroker.new
    randomWord = randomWordBroker.GetRandomWord

    return BASE_URL+randomWord
  end

end
