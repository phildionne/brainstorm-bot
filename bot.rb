require 'dotenv'
Dotenv.load

require 'slack-ruby-bot'
require_relative 'brainstorm'

class BrainstormBot < SlackRubyBot::Bot
  def self.brainstorm
    @@brainstorm ||= Brainstorm.new
  end

  command 'start' do |client, data, match|
    brainstorm.state.start
    brainstorm.start_at = Time.now
    client.say(text: "What problem are you trying to solve?", channel: data.channel)
  end

  command 'stop' do |client, data, match|
    brainstorm.state.stop
    brainstorm.end_at = Time.now

    response = "*#{brainstorm.ideas.count}* ideas in *#{brainstorm.duration}* minutes... Wow, you rock! :the_horns:. Now take a look at your ideaboard and upvote the best ideas: #{brainstorm.board.url}"
    client.say(text: response, channel: data.channel)

    client.say(text: "Type `start` if you want to run another round.", channel: data.channel)
  end

  scan(/hello|hi/) do |client, data, match|
    if brainstorm.state.sleeping?
      client.say(text: "Hey I’m Brian, your brainstorming bot. I can help you find tons of ideas quickly with awesome brainstorming games.", channel: data.channel)
      client.say(text: "Type `start` to start a brainstorm", channel: data.channel)
    end
  end

  scan(/skip|next/) do |client, data, match|
    brainstorm.next_game
    brainstorm.create_game(brainstorm.current_game[:name], brainstorm.board.id)

    response = brainstorm.game_response(brainstorm.current_game)
    client.say(text: response, channel: data.channel)

    response = brainstorm.current_game[:subject]
    client.say(text: response, channel: data.channel)

    response = "Timer set: *#{brainstorm.current_game[:timeout]}* minutes. #{brainstorm.current_game[:cheer]}"
    client.say(text: response, channel: data.channel)
  end

  scan(/(.+)/) do |client, data, match|
    if brainstorm.state.waiting_for_brainstorm_goal?
      brainstorm.state.set_brainstorm_goal
      brainstorm.create_brainstorm(data.text)

      brainstorm.next_game
      brainstorm.create_game(brainstorm.current_game[:name], brainstorm.board.id)

      client.say(text: "Awesome. Let’s get started and get these creative juices flowing!", channel: data.channel)


      response = brainstorm.game_response(brainstorm.current_game)
      client.say(text: response, channel: data.channel)

      response = brainstorm.current_game[:subject]
      client.say(text: response, channel: data.channel)

      response = "Timer set: *#{brainstorm.current_game[:timeout]} minutes*. #{brainstorm.current_game[:cheer]}"
      client.say(text: response, channel: data.channel)

      response = "Type `next` if you want to switch games"
      client.say(text: response, channel: data.channel)

    elsif brainstorm.state.waiting_for_idea?
      brainstorm.create_idea(data.text, brainstorm.current_list.id)
    end
  end
end

BrainstormBot.run
