#!/usr/bin/env ruby

require_relative '../lib/robsim.rb'
include Robsim

require 'p1788'
include P1788

require 'ez_intervals'
include EZ_INTERVALS
include EZ_ALGORITHMS
include EZ_CONTRACTORS

require 'matrix'

class Integer
    def fact
        (1..self).reduce(:*) || 1
    end
end

class MyBot < Robot
	def initialize(wp)
		super()
		set_pos(50, 50)
        set_speed(1)
		set_angle(2*Math::PI*rand)
		add_sensor LandmarkSensor.new(20)
		set_controller PathPlanningController.new(wp, 50)
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
    attr_reader :trajectory       #@return Array[Matrix]
    attr_reader :t_end            #@return Float
    attr_reader :t

    def initialize(wp, tend)
        super()
        @trajectory = wp
        @t_end = tend
        @t=0 
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

        @t = (t + @controller_robot.world.dt)
        puts @t
        if(pos_estimate.empty?)
            return
        end

        if((@t > @t_end))
            @controller_robot.set_speed(0)
            self.rotation = 0
            return
        end
       
        x_ = pos_estimate[0].midpoint
        y_ = pos_estimate[1].midpoint
        #x = Matrix[[@controller_robot.pos.x, @controller_robot.pos.y, @controller_robot.ang, @controller_robot.v]]
        x = Matrix[[x_,  y_ , @controller_robot.ang, @controller_robot.v]]
        w=setpoint(@t/t_end)
        dw=(1/t_end) * d_setpoint(t/t_end)
        u=control_(x, w, dw)
        
        self.rotation = u[0,0]
        self.acceleration = u[0,1]
	end

    def coeff(i, n, t)
        (n.fact()/(i.fact()*(n-i).fact())) * ((1 - t)**(n-i)) * t**i
    end
    
    def d_coeff(i, n, t)
        (n.fact()/(i.fact()*(n-i).fact())) * ((i * (1-t)**(n-i)*(t**(i-1))) - (((1-t)**(n-i-1))*(t**i)))
    end
    
    def setpoint(t)
        w = Matrix[[0],[0]]
        n = (trajectory.length() - 1)
        for i in 0..n do
            w = w + ( coeff(i, n, t) * @trajectory[i])
        end
        return w
    end
    
    def d_setpoint(t)
        dw = Matrix[[0],[0]]
        n = (trajectory.length() - 1)
        for i in 0..n do
            w = dw + ( d_coeff(i, n, t) * trajectory[i])
        end
        return w
    end
    
    def f(x, u) # state = (x, y, thetha, v)
        xdot = Matrix[[x[0,3] * Math.cos(x[0,2]), x[0,3] * Math.sin(x[0,2]), u[0,0], u[0,1]]]
        return xdot
    end
    
    def control_(x, w, dw)
    
        a = Matrix[[-x[0,3] * Math.sin(x[0,2]), Math.cos(x[0,2])], 
                   [ x[0,3] * Math.cos(x[0,2]), Math.sin(x[0,2])]]
    
        y = Matrix[[x[0,0]],
                   [x[0,1]]]
    
        dy = Matrix[[x[0,3] * Math.cos(x[0,2])],
                    [x[0,3] * Math.sin(x[0,2])]]
    
        v = ((w-y) + (2*(dw-dy)))
    
        u_ = a.inverse() * v
        return Matrix[[u_[0,0], u_[1,0]]]
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

circuit_layout = [Matrix[[100], [100]],
                  Matrix[[100], [250]],
                  Matrix[[100], [400]],
                  Matrix[[125], [500]],
                  Matrix[[150], [600]],
                  Matrix[[200], [650]],
                  Matrix[[300], [600]],
                  Matrix[[400], [500]],
                  Matrix[[425], [425]],
                  Matrix[[450], [325]],
                  Matrix[[500], [240]],
                  Matrix[[600], [200]],
                  Matrix[[670], [250]],
                  Matrix[[700], [350]],
                  Matrix[[800], [400]],
                  Matrix[[900], [300]]]

# circuit
circuit_layout.each{|wp|

    s.world.add_waypoint(Waypoint.new(wp[0,0], wp[1,0]))
}

s.world.add_robot(MyBot.new(circuit_layout))
s.simulate(print_cpu_load: true)