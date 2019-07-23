require 'zip'
# require 'loopholes'

class Challenge
  CHALLENGE_URL = 'https://challenge.distribusion.com/the_one'.freeze
  ROUTES_URL    = 'https://challenge.distribusion.com/the_one/routes'.freeze

  SOURCES = %w[loopholes sentinels sniffers].freeze

  def initialize
    response = HTTParty.get(CHALLENGE_URL, headers: {
                              'Accept' => 'application/json'
                            }).body

    pills = Oj.load(response, mode: :compat, object_class: OpenStruct).pills

    @passphrase = pills.red.passphrase

    SOURCES.each { |source| send source }
  end

  def loopholes
    items = extract_data('loopholes')
    rows = Loopholes.new(items).extract
    rows.each { |row| send_data('loopholes', row) }
  end

  def sentinels
    items = extract_data('sentinels')
    rows = Sentinels.new(items).extract
    rows.each { |row| send_data('sentinels', row) }
  end

  def sniffers
    items = extract_data('sniffers')
    rows = Sniffers.new(items).extract
    rows.each { |row| send_data('sniffers', row) }
  end

  def extract_data(source)
    attachment = HTTParty.get(ROUTES_URL, query: {
                                'passphrase' => @passphrase,
                                'source' => source
                              })

    items = {}

    ::Zip::File.open_buffer(attachment.body) do |zip|
      zip.each do |entry|
        next unless entry.ftype == :file && !entry.name.include?('__MACOSX')

        filename = entry.name
        content = entry.get_input_stream.read
        items[filename] = parse_content(filename, content)
      end
    end

    items
  end

  def parse_content(filename, content)
    case File.extname(filename)
    when '.csv'
      CSV.parse(
        content,
        headers: :first_row, converters: :numeric, col_sep: ', '
      ).map(&:to_hash)
    when '.json'
      Oj.load(content, mode: :compat, object_class: OpenStruct)
    end
  end

  def isotime(date_time)
    DateTime.parse(date_time).to_time.utc.strftime('%Y-%m-%dT%H:%M:%S').to_s
  end

  def send_data(source, row)
    response = HTTParty.post(ROUTES_URL,
                             body: { passphrase: @passphrase,
                                     source: source,
                                     start_node: row.start_node,
                                     end_node: row.end_node,
                                     start_time: isotime(row.start_time),
                                     end_time: isotime(row.end_time) })

    puts response.body.force_encoding('UTF-8')
  end
end
