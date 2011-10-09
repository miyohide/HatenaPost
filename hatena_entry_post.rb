require 'rexml/document'
require 'time'
require 'pit'
require 'wsse'
require 'net/http'

class HatenaDiary
   attr_accessor :title, :content, :updated

   def initialize
      @doc = REXML::Document.new
      @doc << REXML::XMLDecl.new('1.0', 'UTF-8')
      @feed = @doc.add_element("entry", {"xmlns" => "http://purl.org/atm/ns#"})
      @title = nil
      @content = nil
      @updated = nil
   end


   def create_post_data
      raise "non title" if !@title
      raise "non content" if !@content
      @updated ||= Time.now.xmlschema

      @feed.add_element("title").add_text @title
      @feed.add_element("content", {'type' => 'text/plain'}).add_text @content
      @feed.add_element("updated").add_text @updated

      s = ""
      @doc.write(s)
      s

   end

end

h = HatenaDiary.new

h.title = "title2"
h.content = "content1"

Net::HTTP.version_1_2

config = Pit.get("hatena")

Net::HTTP.start('d.hatena.ne.jp', 80) {|http|
   response = http.post('/' + config["username"] + '/atom/blog',
                        h.create_post_data,
                        {'X-WSSE' => WSSE::header(config["username"],
                                                  config["password"])})
   case response
   when Net::HTTPCreated then
      puts "diary update done!"
   else
      STDERR.puts "error..."
      puts response
   end
}
