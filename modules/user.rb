class User
  attr_reader :id
  attr_reader :name
  attr_reader :followers_count
  attr_reader :friends_count

  FOLLOWERS_THRESHOLD_COUNT = $conf['user']['followers_threshold_count']
  FRIENDS_THRESHOLD_COUNT   = $conf['user']['friends_threshold_count']

  def initialize(user)
    @id = user.id
    @name = user.name
    @followers_count = user.followers_count
    @friends_count = user.friends_count
  end

  def worth_following?
    followers_count >= FOLLOWERS_THRESHOLD_COUNT && friends_count >= FRIENDS_THRESHOLD_COUNT
  end

  def print_info
    p "<User> ID: #{id}, Name: #{name}, #{followers_count}/#{friends_count}"
  end
end
