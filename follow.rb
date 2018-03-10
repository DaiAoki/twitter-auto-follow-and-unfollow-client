require './client'

client = MyTwitterClient.new

word  = ARGV[0]
count = ARGV[1].to_i

if word && count > 0
  client.auto_follow(word: word, count: count)
else
  client.auto_follow
end
