class Loopholes
  attr_accessor :rows

  def initialize(content)
    @content = content
  end

  def extract
    node_pairs = @content['loopholes/node_pairs.json'].node_pairs
    routes = @content['loopholes/routes.json'].routes

    routes.map do |route|
      node_pair = node_pairs[route.node_pair_id.to_i]
      next unless node_pair

      OpenStruct.new(
        start_node: node_pair.start_node,
        end_node: node_pair.end_node,
        start_time: route.start_time,
        end_time: route.end_time
      )
    end.compact
  end
end
