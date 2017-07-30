class LinebotController < ApplicationController
  require 'line/bot'
  protect_from_forgery :except => [:callback]

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text

          if event.message['text'] == "おはよう"
            message = {
              type: 'text',
              text: "ようこそ うほ"
            }
          else
            message = {
              type: 'text',
              text: event.message['text'] + " うほ"
            }
          end
          #Slack.chat_postMessage(text: 'おがた', username: 'hey', channel: "#hackathon")
          response = client.reply_message(event['replyToken'], message)
          p response
        end
      end
    }
    head :ok
  end

  private
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
