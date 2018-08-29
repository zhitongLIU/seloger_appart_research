require 'nokogiri'
require 'csv'
require 'pp'

def old_buy_analyze(url)
  begin
    `./curl_old.sh #{url}`
    page = Nokogiri::HTML(File.open('./tmp_old.html'))
    price = page.css('a#price')[0].text.strip.gsub('€', '').gsub(' ', '').to_i
    title = page.css('h1.detail-title.title1')[0].text.strip.gsub(' ', '')
    square = title[/\ (.*?)m²/, 1].split.last.to_f
    price_per_square = price / square
    tel = page.css('button.btn-phone.b-btn.b-second.fi.fi-phone.tagClick')[0].attributes.select { |att| att == 'data-phone' }.first.last.value.gsub(' ', '')
    [title || '', url || '', price || '', square || '', price_per_square || '', "#{tel}" || '']
  rescue => e
    puts "  !!errors: #{e}"
    [title || '', url || '', price || '', square || '', price_per_square || '', tel || '']
  end
end

def new_buy_res(url)
  begin
    `./curl_new.sh #{url}`
    page = Nokogiri::HTML(File.open('./tmp_new.html'))
    title = page.css('h1.titleBig.detailInfosTitle')[0].text.strip
    address = page.css('strong')[0].text.strip.gsub(/\s+/, ' ')
    date = page.css('p.summary.detailInfosDate span.txtHighlight').first.text
    [title, url, address, date]
  rescue => e
    puts "  !!errors: #{e}"
    [title || '', url, address || '', date || '']
  end

end

def export_csv(title, res)
  CSV.open("#{title}.csv", "w") do |csv|
    res.each do |line|
      csv << line
    end
  end
end

old_buy_res = [['title', 'link', 'price', 'size', 'price per m2', 'tel']]
new_buy_res = [['title', 'link', 'address', 'date']]

File.open('./in.txt').each do |line|
  url = line.gsub("\n", '')
  puts url
  next unless line.include?('seloger')

  if line.include?('achat') && !line.include?('neuf')
    old_buy_res << old_buy_analyze(url)
  elsif line.include?('neuf') || line.include?('investissement')
    new_buy_res << new_buy_res(url)
  end
end

export_csv("old_buy_out", old_buy_res)
export_csv("new_buy_out", new_buy_res)
