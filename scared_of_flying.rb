require 'matrix'
require 'pqueue'
require 'pry'

PI_VALUE = 3.141592653589793
EARTH_RADIUS = 6378.0
EARTH_CIRCUMFERENCE = 2 * PI_VALUE * EARTH_RADIUS
INFINITY = 1 << 32

class Edge
  attr_accessor :edge_pair1, :edge_pair2
  def initialize(edge_pair1, edge_pair2)
    @edge_pair1 = edge_pair1
    @edge_pair2 = edge_pair2
  end
end

class GraphNode
  attr_accessor :dist_node_pair1, :dist_node_pair2
  def initialize(dist_node_pair1, dist_node_pair2)
    @dist_node_pair1 = dist_node_pair1
    @dist_node_pair2 = dist_node_pair2
  end
end

def convert_to_radian(degree)
  degree * PI_VALUE / 180
end


def convert_to_degree(radian)
  radian * 180 / PI_VALUE
end

def get_city_lat_lng(location_a, location_b, cities)
  return [0, 0 ,0 ,0] if !cities.key?(location_a) || !cities.key?(location_a)
  lat1 = cities[location_a][0]
  lat2 = cities[location_b][0]
  lon1 = cities[location_a][1]
  lon2 = cities[location_b][1]
  lat1 = convert_to_radian(lat1)
  lon1 = convert_to_radian(lon1)
  lat2 = convert_to_radian(lat2)
  lon2 = convert_to_radian(lon2)
  return [lat1, lat2 ,lon1, lon2]
end

def calculate_distance(location_a, location_b, cities)
  lat1, lat2 ,lon1, lon2 = get_city_lat_lng(location_a, location_b, cities)
  array1 = [Math::cos(lat1) * Math::cos(lon1),
                         Math::cos(lat1) * Math::sin(lon1),
                         Math::sin(lat1)]
  array2 = [Math::cos(lat2) * Math::cos(lon2),
                         Math::cos(lat2) * Math::sin(lon2),
                         Math::sin(lat2)]
  vector1 = Vector[*array1]
  vector2 = Vector[*array2]
  vector1_dot_vector2 = vector1.inner_product(vector2)
  angle = Math::acos(vector1_dot_vector2)
  distance = convert_to_degree(angle) / 360.0 * EARTH_CIRCUMFERENCE
  distance.round
end

def calculate_shortest_path(source, edge, n)
  min_distance = []
  for i in 0..(n-1)
    min_distance[i] = INFINITY
  end
  priority_queue = PQueue.new
  min_distance[source] = 0
  priority_queue.push(GraphNode.new(0, source));
  while priority_queue.size != 0
    dist = priority_queue.top.dist_node_pair1
    cur = priority_queue.top.dist_node_pair2
    priority_queue.pop
    next if dist > min_distance[cur]
    for i in 0..(edge[cur].size-1)
      next_loc = edge[cur][i].edge_pair1
      weight = edge[cur][i].edge_pair2
      if (min_distance[cur] + weight < min_distance[next_loc])
        min_distance[next_loc] = min_distance[cur] + weight
        priority_queue.push(GraphNode.new(min_distance[next_loc], next_loc));
      end
    end
  end
  min_distance
end

edge = []
no_of_case = 1
while (user_input = gets.split.map(&:to_i))
  break if user_input[0] == 0
  n, m , q = user_input
  cities = {}
  city_name = {}
  for i in 0..n
    edge[i].clear if edge[i].class == 'Array'
  end
  for i in 0..(n-1)
    city_lat_lng = gets.chomp
    name, lat, lng = city_lat_lng.split(' ')
    cities[name] ||= []
    cities[name] << lat.to_f
    cities[name] << lng.to_f
    city_name[name] = i
  end
  for i in 0..(m-1)
    connecting_flights = gets.chomp
    loc1, loc2 = connecting_flights.split(' ')
    weight = calculate_distance(loc1, loc2, cities)
    edge[city_name[loc1]] ||= []
    edge[city_name[loc1]] << Edge.new(city_name[loc2], weight)
  end
  puts "Case #" + no_of_case.to_s
  for i in 0..(q-1)
    queries = gets.chomp
    query1 , query2 = queries.split(' ')
    min_distance_arrya = calculate_shortest_path(city_name[query1], edge, n)
    result = city_name[query2].nil? ? INFINITY : min_distance_arrya[city_name[query2]]
    if query1.to_s == query2.to_s
      puts 'No Shortest path avaiable between same city enter valid city name'
    elsif (result >= INFINITY)
      puts 'no route exists';
    else
      puts result.to_s + 'km';
    end
  end
  no_of_case +=1
  puts ''
end
