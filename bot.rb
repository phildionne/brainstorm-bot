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

    duration = (brainstorm.start_at - brainstorm.end_at) / 60

    response = "#{brainstorm.ideas.count} ideas in #{duration} minutes... Wow, you rock! :the_horns:. Now take a look at your ideaboard and upvote the best ideas: #{brainstorm.board.url}. Type start if you want to run another round or exit to quit the brainstorm."
    client.say(text: response, channel: data.channel)
  end

  command 'skip' do |client, data, match|
    brainstorm.next_game

    response = brainstorm.game_response(brainstorm.current_game)
    client.say(text: response, channel: data.channel)
  end

  scan(/(.+)/) do |client, data, match|
    if brainstorm.state.waiting_for_brainstorm_goal?
      brainstorm.state.set_brainstorm_goal
      brainstorm.create_brainstorm(data.text)
      brainstorm.new_game

      client.say(text: "Awesome. Let’s get started and get these creative juices flowing!", channel: data.channel)

      brainstorm.create_game(brainstorm.current_game[:name], brainstorm.board.id)
      response = brainstorm.game_response(brainstorm.current_game)
      client.say(text: response, channel: data.channel)

    elsif brainstorm.state.waiting_for_idea?
      brainstorm.create_idea(data.text, brainstorm.current_list.id)
    end
  end
end

BrainstormBot.run
