require 'net/http'
require 'open-uri'
require 'json'
require 'launchy'

options = [
  {
    command: 'List All Breeds',
    url: 'https://dog.ceo/api/breeds/list/all',
    responseType: 'list',
    hasWhichBreedQuestion: false
  },
  {
    command: 'Random Image',
    url: 'https://dog.ceo/api/breeds/image/random',
    responseType: 'image',
    hasWhichBreedQuestion: false
  },
  {
    command: 'Random Image For Breed',
    url: "https://dog.ceo/api/breed/%s/images",
    responseType: 'image',
    hasWhichBreedQuestion: true
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

def prompt_for_user_input(options)
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
    input = prompt_for_user_input options
    choice = options[input.chomp.to_i]

    if choice[:hasWhichBreedQuestion]
      puts 'What breed do you want to see?'
      breed_name = gets
      choice[:url] = choice[:url] % breed_name.strip
    end

    response = process_uri choice

    if choice[:responseType] == 'list'
      JSON.parse(response)['message'].each do |breed|
        puts breed
      end
    else
      save_image response
      puts 'Image Saved!'
      Launchy.open './dog.png'
    end
  end
rescue Interrupt
  puts "\nThanks for stopping by!"
end
