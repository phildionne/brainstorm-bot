require 'random-word'
require 'aasm'
require 'trello'
require './random_meme'

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_API_KEY']
  config.member_token = ENV['TRELLO_TOKEN']
end

class Brainstorm
  attr_accessor :current_games, :state, :board, :current_list, :current_game, :ideas, :start_at, :end_at

  def initialize
    @state = State.new
    @ideas = Array.new
    @current_games = Array.new
  end

  def games
    [
      {
        name: "Word Up",
        description: "My first game is called *Word Up*: I shoot you a random word and you pitch an idea in relation to the word. ",
        subject: "The words is: *#{RandomWord.nouns.next}*",
        cheer: "Let’s go! :rocket:",
        timeout: 3
      },
      {
        name: "Meme Dream",
        description: "Let’s build on that momentum with a game called *Meme Dream*. Here’s how it works: I show you a meme and you brainstorm ideas that tie it back to the problem you’re trying to solve.",
        subject: "The meme is: #{RandomMeme.get_url}",
        cheer: "Bring it on! :rocket:",
        timeout: 2
      },
      {
        name: "Sci-Fi",
        description: "Let’s play a game called: *Sci-Fi*...",
        subject: "*If you lived in 2080, how would you solve your problem?*",
        cheer: "Keep firing up ideas! :raised_hands:",
        timeout: 3
      }
    ]
  end

  # Sets the current game to a new game and creates a Trello List
  def next_game
    if current_games.none?
      self.current_games = self.games
    end

    self.current_game = current_games.shift
  end

  # @param name [String]
  def create_brainstorm(name)
    args = {
      name: name,
      description: "",
      organization_id: "57531ae83624aac46729f166",
      prefs: {
        permissionLevel: 'org'
      }
    }
    self.board = Trello::Board.create(args)
    self.board.lists.each(&:close!)
  end

  # @param name [String]
  # @param board_id [String]
  def create_game(name, board_id)
    self.current_list = Trello::List.create(name: name, board_id: board_id);
  end

  # @param text [String]
  # @param list_id [String]
  def create_idea(text, list_id)
    @ideas << text
    Trello::Card.create(name: text, desc: "", list_id: list_id)
  end

  # @return [String]
  def game_response(game)
    game[:description]
  end

  # @return [Float] duration in minutes
  def duration
    ((end_at - start_at) / 60).round(2)
  end
end

class State
  include AASM

  aasm do
    state :sleeping, initial: true
    state :waiting_for_brainstorm_goal
    state :waiting_for_idea

    event :start do
      transitions from: :sleeping, to: :waiting_for_brainstorm_goal
    end

    event :set_brainstorm_goal do
      transitions from: :waiting_for_brainstorm_goal, to: :waiting_for_idea
    end

    event :stop do
      transitions from: :waiting_for_idea, to: :sleeping
    end
  end
end
