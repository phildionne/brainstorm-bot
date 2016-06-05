require 'aasm'
require 'trello'

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_API_KEY']
  config.member_token = ENV['TRELLO_TOKEN']
end

class Brainstorm
  GAMES = [
    {
      name: "Word Up",
      description: "My first game is called Word Up: I shoot you a random word and you pitch an idea in relation to the word. ",
      example: "example"
    },
    {
      name: "Meme Dream",
      description: "5 ideas :raised_hands:. Let’s build on that momentum with a game called Meme Dream. Here’s how it works: I show you a meme and you brainstorm ideas that tie it back to the problem you’re trying to solve.",
      example: "example"
    },
    {
      name: "Sci-Fi",
      description: "12 ideas: you guys are on :fire:. Let’s play another game called: Sci-Fi... Type go to get started,  help if you don’t understand OR next if you want to switch games.",
      example: "example"
    }
  ]

  attr_accessor :state, :board, :current_list, :current_game, :ideas, :start_at, :end_at

  def initialize
    @state = State.new
    @ideas = Array.new
  end

  # Sets the current game to a new game and creates a Trello List
  def next_game
    self.new_game
    create_game(self.current_game[:name], self.board.id)
  end

  # Sets the current game to a new game
  def new_game
    self.current_game = GAMES.sample
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
