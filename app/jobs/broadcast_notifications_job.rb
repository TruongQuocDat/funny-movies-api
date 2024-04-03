# frozen_string_literal: true

class BroadcastNotificationsJob < ApplicationJob
  queue_as :default

  def perform(args)
    payload = {
      title: args[:title],
      user: args[:user]
    }

    ActionCable.server.broadcast 'notification_channel', payload
  end
end
