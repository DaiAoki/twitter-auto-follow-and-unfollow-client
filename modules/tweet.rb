class Tweet
  attr_reader :id
  attr_reader :favorite_count
  attr_reader :text

  FAVORITE_THRESHOLD_COUNT = $conf['tweet']['favorite_threshold_count']

  def initialize(tweet)
    @id = tweet.id
    @favorite_count = tweet.favorite_count
    @text = tweet.text
  end

  def worth_following?
    favorite_count >= FAVORITE_THRESHOLD_COUNT
  end

  def print_info
    p "<Tweet> ID: #{id}, Fav: #{favorite_count}"
    p "=============================="
    p text
    p "=============================="
  end
end
