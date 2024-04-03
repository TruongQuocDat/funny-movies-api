# frozen_string_literal: true

class YoutubeService
  include HTTParty

  BASE_URL = 'https://www.googleapis.com/youtube/v3/videos'

  def initialize(youtube_url)
    @youtube_url = youtube_url
  end

  attr_reader :youtube_url

  def call
    youtube_id = extract_id_from_url(youtube_url)
    fetch_video_info(youtube_id)
  end

  private

  def fetch_video_info(youtube_id)
    response = HTTParty.get(BASE_URL, query: {
                              id: youtube_id,
                              part: 'snippet',
                              key: ENV.fetch('YOUTUBE_API_KEY', nil)
                            })
    if response.success?
      snippet = response.parsed_response['items'].first['snippet']
      {
        title: snippet['title'],
        description: snippet['description']
      }
    else
      { error: 'Failed to fetch video information' }
    end
  end

  def extract_id_from_url(url)
    URI.parse(url).query.split('&').find { |param| param.start_with?('v=') }.split('=').last
  rescue StandardError
    nil
  end
end
