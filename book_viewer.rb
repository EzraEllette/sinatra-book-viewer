require "sinatra"
require "sinatra/reloader"
require 'tilt/erubis'

before do
  @contents = File.readlines('data/toc.txt')
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map.with_index { |line, index| "<p id=\"section#{index + 1}\">#{line}</p>"}
  end

  def search_by_term(term)
    results = {}
    return nil if term.nil?

    File.readlines("data/toc.txt").each_with_index do |chapter, index|
      file = File.read("data/chp#{ index + 1 }.txt")
      if file.include?(term) || chapter.include?(term)
        sections = in_paragraphs(file).each_with_object({}).with_index do |(pa, hash), i|
           if pa.include?(term)
            hash[i + 1] = pa
           end
        end
        results[chapter] = { index: index + 1, paragraphs: sections }
      end
    end
    results
  end

  def highlight(text, term)
    text.gsub(term, "<strong>#{term}</strong>")
  end
end

not_found do
  redirect "/"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes | Home Page"

  erb :home
end

get "/chapters/:number" do

  number = params['number'].to_i
  redirect "/" unless @contents.size >= number
  @chapter = @contents[number - 1]
  @title = "Chapter #{number} | #{@chapter}"
  @text = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/search" do
  @results = search_by_term(params[:query])
  erb :search
end

post "/search" do
  @results = search_by_term(params[:query])
  erb :search
end
