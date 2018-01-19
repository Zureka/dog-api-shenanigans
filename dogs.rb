require 'net/http'
require 'open-uri'
require 'json'
require 'launchy'

$options = [
  {:command => "List All Breeds", :url => "https://dog.ceo/api/breeds/list/all", :responseType => "list"},
  {:command => "Random Image", :url => "https://dog.ceo/api/breeds/image/random", :responseType => "image"},
  {:command => "Random Borzoi Image", :url => "https://dog.ceo/api/breed/borzoi/images", :responseType => "image"},
]

def save_image response
  message = JSON.parse(response)["message"]

  if message.is_a? String then
    image_uri = message
  else
    image_uri = message.sample
  end

  File.open("dog.png", 'wb') do |fo|
    fo.write open(image_uri).read
  end
end

def get_user_input
  puts "\nWhat would you like to look for?"

  $options.each_with_index do |key, index|
    puts "  " + index.to_s + ". " + key[:command]
  end

  gets
end

def process_uri choice
  escaped_address = URI.escape choice[:url]
  uri = URI.parse escaped_address

  puts "\nGetting " + choice[:command] + ":"

  Net::HTTP.get(uri)
end

puts "Welcome to the Dog Finder List Thing!"

begin
  while true do
    input = get_user_input
    choice = $options[input.chomp.to_i]
    response = process_uri choice

    if choice[:responseType] === "list" then
      puts response
    else
      save_image response
      puts "Image Saved!"
      Launchy.open "./dog.png"
    end
  end
rescue Interrupt
ensure
  puts "\nThanks for stopping by!"
end
