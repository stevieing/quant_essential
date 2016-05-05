class SequencescapeSearch

  SearchNotFound = Class.new(StandardError)

  # Passed into SequencescapeSearch and describes a particular search
  # name: The name of a search
  # parameter: The search parameter name passed in the post
  # return_map: A hash of keys that will be returned, and their 'address' in the json response
  SearchEndpoint = Struct.new(:name,:parameter,:return_map)

  def self.swipecard_search
    SequencescapeSearch::SearchEndpoint.new('Find user by swipecard code','swipecard_code',{:uuid=>['user','uuid'],:login=>['user','login']})
  end

  def self.plate_barcode_search
    SequencescapeSearch::SearchEndpoint.new('Find assets by barcode','barcode',{:uuid=>['plate','uuid'],:name=>['plate','name'],:external_type=>["plate","plate_purpose","name"]})
  end

  attr_reader :api_root, :search_endpoint, :search

  # api_root: A Faraday client pointed at the api root
  # search: A SearchEndpoint
  # search_endpoint: [optional] the name of the searches resource itself
  def initialize(api_root,search,search_endpoint='searches')
    @api_root = api_root
    @search = search
    @search_endpoint = search_endpoint
  end

  def find(query)
    payload = { singlular_endpoint => {parameter => query} }.to_json
    resp = api_root.post(search_root,payload)
    json = JSON.parse(resp.body)
    Hash[return_map.map {|k,v| [k,json.dig(*v)] } ]
  end

  private

  delegate :name, :parameter, :return_map, :to => :search

  def singlular_endpoint
    search_endpoint.singularize
  end

  def search_root
    @search_root ||= "/#{search_uuid}/first"
  end

  def search_uuid
    searches = api_root.get(search_endpoint)
    json = JSON.parse(searches.body)
    found_search = json.fetch(search_endpoint).detect {|search| search["name"] == name }
    raise SearchNotFound, "Could not find search #{name}" if found_search.nil?
    found_search["uuid"]
  end

end
