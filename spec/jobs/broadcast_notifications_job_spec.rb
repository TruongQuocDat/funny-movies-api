# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BroadcastNotificationsJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later(args) }

  let(:args) do
    {
      title: 'New Video 123',
      user: 'Gabriel'
    }
  end

  it 'queues the job' do
    expect { job }.to have_enqueued_job(described_class)
      .with(args)
      .on_queue('default')
  end

  it 'broadcasts notification to the channel' do
    expect(ActionCable.server).to receive(:broadcast)
      .with('notification_channel', args)

    perform_enqueued_jobs { job }
  end
end
