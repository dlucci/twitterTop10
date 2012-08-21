require 'rubygems' 
require 'sinatra'
require 'net/http'
require 'json'

def getTweets(handle)
 uriPrefix = 'http://api.twitter.com/1/statuses/user_timeline.json?include_rts=true&screen_name=' 
 uriSuffix = '&count=200'

 tweets = ''
 text = ''
 textData = ''
 if handle == ''
   return -1
 end    
 begin
   x = 0
   while x < 5
     res = Net::HTTP.get_response(URI.parse(uriPrefix +handle +'&page=' +  x.to_s + uriSuffix ))
     apiData = res.body
     tweets = JSON.parse(apiData)
     tweets.size.times do |c|
       text = tweets[c]['text']
       textData += (text + ' ')
     end
     if tweets.size <199 && tweets.size > 0
      break
     end
     x+=1 
   end
   textData = textData.split(' ')
   rescue
     return -2
   end
  return textData
end


def wordFreq(data)
  twitterFreq = Hash.new(0)
  data.each { |word| 
                  word = word.gsub(/\W/, '')
                  if word.size > 0
                    twitterFreq[word.downcase] += 1
                  end
                }
  twitterFreq = twitterFreq.sort_by{|key, value| value}.reverse
  return twitterFreq
end


def printFreqWords(twitterFreq)
  #twitterFreq.each { |word, freq| puts word, freq }
  #puts twitterFreq.sort_by {|word, freq| -freq}[0..4]
  output = ""
  twitterFreq.first(10).each do |word, freq| 
    output << "#{word}:  #{freq} <br>"
  end
  return output
end

get '/' do
  erb :tweet
end

get '/dataError' do
  erb :dataError
end

get '/handleError' do
  erb :handleError
end
post '/form' do
  tweets = getTweets(params[:handle])
  if tweets == -1
    redirect '/handleError'
  end
  if tweets == -2
    redirect '/dataError'
  end
  wordHash = wordFreq(tweets)
  #return printFreqWords(wordHash)
  output = printFreqWords(wordHash)
  return output
end

=begin error 400..510 do
  erb :error
=end
