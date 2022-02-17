#!/usr/bin/env ruby

require_relative '../lib/robsim.rb'
include Robsim

require 'p1788'
include P1788

require 'ez_intervals'
include EZ_INTERVALS
include EZ_ALGORITHMS
include EZ_CONTRACTORS

class MyBot < Robot
	def initialize(wp)
		super()
		set_pos(50, 50)
		set_angle(2*Math::PI*rand)
		add_sensor LandmarkSensor.new(20)
		set_controller PathPlanningController.new(wp)
	end
end

class LandmarkSensor < Sensor

    attr_reader :accuracy  #@return [Float]

	def initialize(accuracy)
		super(:sense_landmarks)
        @accuracy = accuracy
	end

	def update
        detections = []
		@robot.world.landmarks.each{|mark| 
			pos = mark.pos - @robot.pos
			distance_to_robot = pos.length
			down_approx = rand(0.0..@accuracy)
            up_approx = rand(0.0..@accuracy)
            distance = Interval[distance_to_robot - down_approx, distance_to_robot + up_approx]
            detections.append(EZ_TYPES::Disk.new(mark.pos.x, mark.pos.y, distance))
		}
		self.value = detections
	end
end

class PathPlanningController < Controller

    attr_reader :pos_estimate_raw #@return Array[IntervalVector]
    attr_reader :pos_estimate     #@return [IntervalVector]
    attr_reader :trajectory       #@return [Vec2]
    attr_reader :waypoint_index   #@return [Integer]

    def initialize(wp)
        super()
        @trajectory = wp
        @waypoint_index = 0
    end

	def observe
		# Find landmarks
		mark_detections = sensor(:sense_landmarks)
        searchspace = IntervalVector[Interval[0, @controller_robot.world.width], Interval[0, @controller_robot.world.height]]
        @pos_estimate_raw, bon, ball = sivia(searchspace, 1) {|b| s_interdisks(b, mark_detections, false)}
        compute_pos_estimate()
	end

    def compute_pos_estimate()
        @pos_estimate = IntervalVector[Interval::EMPTY_SET, Interval::EMPTY_SET]
        pos_estimate_raw.each{|box|
            @pos_estimate = (@pos_estimate | box)            
        }
    end

	def control

        x = pos_estimate[0].midpoint
        y = pos_estimate[1].midpoint
        pos = trajectory[waypoint_index] - Vec2.new(x, y)
        angle =  pos.angle()
        diff = (@controller_robot.ang - angle).abs()

        if(diff > 0.3)
            puts "rotating"
            self.rotation = 0.5
            self.acceleration = 0
        else
            puts "not rotating"
            self.rotation = 0
            self.acceleration = 1
        end


        if(next_wp_reached?)

            @waypoint_index = (@waypoint_index + 1)
            if(@waypoint_index >= trajectory.length)
                @waypoint_index  = 0
            end
        end

        puts "next wp is " + @waypoint_index.to_s
	end

    def next_wp_reached?
        x = pos_estimate[0].midpoint
        y = pos_estimate[1].midpoint
        pos = trajectory[waypoint_index] - Vec2.new(x, y)
        distance = pos.length

        if(distance <= 5)
            return true
        end
        
        return false
    end

    def draw(figure)
        if(pos_estimate.nil?)
            return
        end
        figure.remove_object @id
        figure.draw_box(pos_estimate,  'K[M]', name: @id)
    end

	def main
		loop do
			observe()
			control()
			wait_next_step()
		end
	end
end

s = Simulator.new
10.times do
    pos_x = rand(0.0..s.world.width)
    pos_y = rand(0.0..s.world.height)
	s.world.add_landmark(Landmark.new(pos_x, pos_y))
end

circuit_layout = [Vec2.new(100, 100),
                  Vec2.new( 75, 400),
                  Vec2.new(200, 600),
                  Vec2.new(400, 500),
                  Vec2.new(750, 600),
                  Vec2.new(900, 250),
                  Vec2.new(500, 125)]
# circuit
circuit_layout.each{|wp|

    s.world.add_waypoint(Waypoint.new(wp.x, wp.y))
}

s.world.add_robot(MyBot.new(circuit_layout))
s.simulate(print_cpu_load: true)