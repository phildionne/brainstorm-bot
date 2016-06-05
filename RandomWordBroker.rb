class RandomWordBroker
  require 'random-word'

  def GetRandomWord

    random = 1 + Random.rand(2)

    if random > 0
      return RandomWord.adjs.next
    else
      return RandomWord.nouns.next
    end

  end

end
