require 'twitter'
require 'date'
require 'yaml'
require './config/setting'

require 'byebug'
require 'pry'

Dir[File.expand_path('../modules', __FILE__) << '/*.rb'].each do |file|
  require file
end

class MyTwitterClient
  attr_reader :client

  AUTH_CONSUMER_KEY        = $conf['authorization']['consumer_key']
  AUTH_CONSUMER_SECRET     = $conf['authorization']['consumer_secret']
  AUTH_ACCESS_TOKEN        = $conf['authorization']['access_token']
  AUTH_ACCESS_TOKEN_SECRET = $conf['authorization']['access_token_secret']
  DEFAULT_SEARCH_WORD      = $conf['client']['default_search_word']
  DEFAULT_SEARCH_COUNT     = $conf['client']['default_search_count']
  DEFAULT_SEARCH_TERM      = $conf['client']['default_search_term']

  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = AUTH_CONSUMER_KEY
      config.consumer_secret     = AUTH_CONSUMER_SECRET
      config.access_token        = AUTH_ACCESS_TOKEN
      config.access_token_secret = AUTH_ACCESS_TOKEN_SECRET
    end
  end

  def confirm_setup_authorization
    p "ID:          #{client.user.screen_name}"
    p "Name:        #{client.user.name}"
    p "Description: #{client.user.description}"
  end

  def auto_follow(word: DEFAULT_SEARCH_WORD, count: DEFAULT_SEARCH_COUNT)
    search_term = (Date.today - DEFAULT_SEARCH_TERM).to_s
    follow_success_count = 1

    client.search(word, options: {until: search_term}).take(count).each do |tweet|
      tweet_obj = Tweet.new(tweet)
      user_obj  = User.new(tweet.user)

      next unless worth_following?(tweet: tweet_obj, user: user_obj)

      begin
        next if already_followed?(user_obj.id) || already_following?(user_obj.id)
        client.follow(user_obj.id)
      rescue => e
        p e
        p "Unexpected Error when user-id is #{user_obj.id}."
        next
      end

      print_follow_info(tweet: tweet_obj, user: user_obj, count: follow_success_count)
      follow_success_count += 1
    end
  end

  def auto_unfollow
    unfollow_candidates_ids = client.friend_ids.attrs[:ids] - client.follower_ids.attrs[:ids]
    unfollow_candidates_ids.each do |id|
      unfollow_candidate = client.user(id)
      # TODO: ここで一定の条件を満たしたユーザーは除外するようにオプションで設定できるようにする
      print_candidate_info(unfollow_candidate)
      p 'unfollow this user? (y/n/allno) '
      loop do
        case gets.chomp
        when 'y', 'yes', 'YES'
          client.unfollow(unfollow_candidate.id)
          break
        when 'n', 'no',  'NO'
          break
        when 'allno'
          return
        else
          p 'please enter y/n '
        end
      end
    end
  end


  private

    def worth_following?(tweet:, user:)
      tweet.worth_following? || user.worth_following?
    end

    def already_followed?(user_id)
      client.follower_ids.include?(user_id)
    end

    def already_following?(user_id)
      client.friend_ids.include?(user_id)
    end

    def print_follow_info(tweet:, user:, count: 9999)
      p "Success!!! #{count}th."
      user.print_info
      tweet.print_info
    end

    def print_candidate_info(user)
      p "ID: #{user.id}, Name: #{user.name}"
      p "Follower: #{user.followers_count}, Friend: #{user.friends_count}"
    end
end
