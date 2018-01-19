require 'net/http'
require 'open-uri'
require 'json'
require 'launchy'

options = [
  {
    command: 'List All Breeds',
    url: 'https://dog.ceo/api/breeds/list/all',
    responseType: 'list'
  },
  {
    command: 'Random Image',
    url: 'https://dog.ceo/api/breeds/image/random',
    responseType: 'image'
  },
  {
    command: 'Random Borzoi Image',
    url: 'https://dog.ceo/api/breed/borzoi/images',
    responseType: 'image'
  },
]

def save_image(response)
  message = JSON.parse(response)['message']

  image_uri =
    if message.is_a? String
      message
    else
      message.sample
    end

  File.open('dog.png', 'wb') do |fo|
    fo.write open(image_uri).read
  end
end

def acquire_user_input(options)
  puts "\nWhat would you like to look for?"

  options.each_with_index do |key, index|
    puts '  ' + index.to_s + '. ' + key[:command]
  end

  gets
end

def process_uri(choice)
  uri = URI.parse choice[:url]
  puts "\nGetting " + choice[:command] + ':'
  Net::HTTP.get(uri)
end

puts 'Welcome to the Dog Finder List Thing!'

begin
  loop do
    input = acquire_user_input options
    choice = options[input.chomp.to_i]
    response = process_uri choice

    if choice[:responseType] == 'list'
      puts response
    else
      save_image response
      puts 'Image Saved!'
      Launchy.open './dog.png'
    end
  end
rescue Interrupt
  puts "\nThanks for stopping by!"
end
