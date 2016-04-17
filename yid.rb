require 'thor'
require 'net/http'
require 'pstore'
require 'nokogiri'
require 'open-uri'
require 'pp'

# TODO: ここを変更
BASE_URL = "https://github.com"

Yinfo = Struct.new(:name, :img) do
  def sum
  end

  def minus
  end
end

def save(yinfo)
  db = PStore.new('pstore.db')
  db.transaction do
    if db["id"].nil? 
      db["id"] = []
    end
    
    if db["id"].map {|yinfo| yinfo.name}.include?(yinfo.name) 
      # 保存済み
      return 
    end
    db["id"] = db["id"] + [yinfo]
  end
end

def meta(id)
  url = "#{BASE_URL}/#{id}"

  begin
    html = open(url)
  rescue
    return nil
  end
  doc = Nokogiri::HTML(html.read, nil, 'utf-8')

  begin
    # TODO: ここを変更
    s = doc.css("img.avatar.rounded-2").attribute("src").value
    return Yinfo.new(id, s)
  rescue
    return nil
  end
end

class SampleCLI < Thor
  desc "command1 usage", "command1 desc"
  def yopen(id)
    s = "#{BASE_URL}/#{id}"

    code = Net::HTTP.get_response(URI.parse(s)).code
    if code == "404"
      puts "404 error"
      exit
    end

    `open #{s}`

    yinfo = meta(id)
    if yinfo.nil?
      exit
    end
    save(yinfo)
  end

  desc "command2 usage", "command2 desc"
  def ylist
    db = PStore.new('pstore.db')

    db.transaction do
      if db["id"].nil?
          db["id"] = []
      end
      pp db["id"]
    end
  end
end

SampleCLI.start(ARGV)
