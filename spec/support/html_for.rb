module HtmlFor
  def html_for(filename)
    file = File.join(File.dirname(__FILE__), '../examples', filename)
    File.read(file).sub(/.*?(<!DOCTYPE html>.*)/m, '\1')
  end
end
