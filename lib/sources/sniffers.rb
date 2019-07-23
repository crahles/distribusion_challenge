class Sniffers
  attr_accessor :rows

  def initialize(content)
    @content = content
  end

  def extract
    sequences = @content['sniffers/sequences.csv']
    routes = @content['sniffers/routes.csv']
    node_times = @content['sniffers/node_times.csv']

    sequences.map do |sequence|
      route_id = sequence['route_id']
      route = routes[route_id]

      node_time_id = sequence['node_time_id']
      node_time = node_times[node_time_id]
      next unless node_time

      duration = node_time['duration_in_milliseconds'] / 1000
      start_time = DateTime.parse(
        route['time'] + route['time_zone']
      ).to_time.utc
      end_time = start_time + duration

      OpenStruct.new(
        start_node: node_time['start_node'],
        end_node: node_time['end_node'],
        start_time: start_time.to_s,
        end_time: end_time.to_s
      )
    end.compact
  end
end
