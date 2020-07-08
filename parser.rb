# подключаем всё необходимое
require 'open-uri'
require 'nokogiri'
require 'csv'

# пример запуска ruby parser.rb https://www.petsonic.com/snacks-huesos-para-perros/ table.csv
# ссылка на страницу категории
url_value = ARGV.first
# имя файла в который будет записан результат
file_name = ARGV.last

# открываем файл csv
CSV.open(file_name, 'w') do |csv|
  csv << %w[Name Price Image]

  # идём по ссылкам
  doc = Nokogiri::HTML(open(url_value))
  doc.xpath('.//a[@class="product-name"]/@href').each do |url|
    puts "loading from #{url}"

    # проходим на целевую страницу
    page = Nokogiri::HTML(open(url))
    # парсим
    items = page.xpath('//*[@id="center_column"]')
    name_item = items.xpath('//h1[@class="product_main_name"]/text()')
    img_item = items.xpath('//*[@id="bigpic"]/@src').text
    # проверяем дополнительные категории
    items.xpath('//fieldset[@class="attribute_fieldset"]').each do |val|
      peso_item = val.xpath('.//span[@class="radio_label"]/text()')
      price_item = val.xpath('.//span[@class="price_comb"]/text()').to_s.to_f

      # записываем в csv
      csv << ["#{name_item} - #{peso_item}", price_item, img_item]

    end
  end
end

puts 'Done !!!'