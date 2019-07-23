class Sentinels
  attr_accessor :rows

  def initialize(content)
    @content = content
  end

  def extract

    routes = @content['sentinels/routes.csv']

    routes.map do |route|
      next unless node_available route['node']
      OpenStruct.new(
        start_node: route['node'],
        end_node: route['node'],
        start_time: route['time'],
        end_time: route['time']
      )
    end.compact
  end

  def node_available(node)
    %w[alpha beta gamma delta theta lambda tau psi omega].include? node
  end
end
