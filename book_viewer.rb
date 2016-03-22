require "pry"
require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |paragraph, index|
      "<p id=paragraph#{index}>#{paragraph}</p>"
    end.join
  end

  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end
end

get "/list" do
#  @files = Dir.glob("public/*").each {|file| file.gsub!("public/","")}.sort
#  @files.reverse! if params[:sort] == "desc"
  @files = Dir.glob("public/*").map {|file| File.basename(file) }.sort
  @files.reverse! if params[:sort] == "desc"
  erb :list
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number-1]
  @title = "Chapter #{number}: #{chapter_name}"

  @chapter_contents = File.read("data/chp#{number}.txt")  

  erb :chapter
end

get "/search" do
  if params[:query]
    query = params[:query]
    @results = @contents.each_with_index.each_with_object([]) do |(chapter, chapter_number), result|
      text = File.read("data/chp#{chapter_number + 1}.txt")
      paragraphs = text.split("\n\n")
      paragraphs.each_with_index do |(paragraph,paragraph_index)|    
        result << [chapter, chapter_number+1, paragraph, paragraph_index] if paragraph.include?(query)
      end
    end
  end

  erb :search
end

not_found do
  redirect "/"
end
