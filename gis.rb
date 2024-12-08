#!/usr/bin/env ruby
require 'json'

class Track
    def initialize(track_coordinates, name=nil)
        @name = name
        @track_coordinates = track_coordinates.map { |c| Coordinates.new(c) }
    end
    
    # creates a JSON for the Track
    def get_track_json()
        feature = {
            type: "Feature",
            properties: @name ? {title: @name} : {},
            geometry: {
                type: "MultiLineString",
                coordinates: []
            }
        }
        
        if @name != nil
            feature[:properties][:title] = @name
        end
        
        feature[:geometry][:coordinates] = @track_coordinates.map do |track_c|
            track_c.coordinates.map do |c|
                coords = [c.lon, c.lat]
                if c.ele != nil
                    coords << c.ele
                end
                coords
            end
        end
        
        JSON.generate(feature)
    end

    def to_geojson
        JSON.parse(get_track_json)
    end
end

class Waypoint
    attr_reader :lat, :lon, :ele, :name, :type

    def initialize(lon, lat, ele=nil, name=nil, type=nil)
        @lat = lat
        @lon = lon
        @ele = ele
        @name = name
        @type = type
    end

    def get_waypoint_json(indent=0)
        feature = {
            type: "Feature",
            properties: @name ? {title: @name} : {},
            geometry: {
                type: "Point",
                coordinates: ele ? [lon, lat, ele] : [lon, lat]
            }
        }
        
        if name || type
            feature[:properties] = {}
            feature[:properties][:title] = name if name
            feature[:properties][:icon] = type if type
        end
        
        JSON.generate(feature)
    end

    def to_geojson
        JSON.parse(get_waypoint_json)
    end
end

class World
    def initialize(name, features)
        @name = name
        @features = features
    end
    
    def add_feature(f)
        @features.append(t)
    end

    def to_geojson
        {
            type: "FeatureCollection",
            features: @features.map do |feature|
                case feature
                    when Track then feature.to_geojson
                    when Waypoint then feature.to_geojson
                end
            end
        }.to_json
    end
end

class Point
    attr_reader :lat, :lon, :ele
  
    def initialize(lon, lat, ele=nil)
        @lon = lon
        @lat = lat
        @ele = ele
    end
end

class Coordinates
    attr_reader :coordinates
    def initialize(coordinates)
        @coordinates = coordinates
    end
end

def main()
    w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
    w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
  
    ts1 = [Point.new(-122, 45), Point.new(-122, 46), Point.new(-121, 46),]
    ts2 = [ Point.new(-121, 45), Point.new(-121, 46)]
    ts3 = [Point.new(-121, 45.5), Point.new(-122, 45.5)]

    t = Track.new([ts1, ts2], "track 1")
    t2 = Track.new([ts3], "track 2")

    world = World.new("My Data", [w, w2, t, t2])

    puts world.to_geojson()
end

if __FILE__ == $0
    main
end
