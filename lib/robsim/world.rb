# Copyright (C) 2022 Théotime Bollengier <theotime.bollengier@ensta-bretagne.fr>
#                    Pierre Filiol       <pierre.filiol@netc.fr>
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>. 

require 'vibes-rb'

module Robsim
	class World
		attr_reader   :simulator       #@return [Simulator]
		attr_reader   :width, :height  #@return [Integer]
		attr_reader   :bodies          #@return [Array<Body>]
		attr_reader   :robots          #@return [Array<Robot>]
        attr_reader   :landmarks       #@return [Array<Landmark>]
		attr_reader   :waypoints       #@return [Array<Waypoint>]
		attr_reader   :dt              #@return [Float]


		def initialize(width = 1280, height = 720)
			@simulator = nil
			@width = [10, width.to_i].max
			@height = [10, height.to_i].max
			@bodies = []
			@robots = []
            @landmarks = []
			@waypoints = []
		end

		def draw
			open_figure()
			@bodies.each{|b| b.draw(@figure)}
		end

		def simulator=(s)
			raise "expecting a #{Simulator}, which #{s} is not" unless s.is_a?(Simulator)
			raise "attribute :simulator already set for #{self}" unless @simulator.nil?
			@simulator = s
		end

		def add_robot(r)
			raise "expecting a #{Robot}, which #{r} is not" unless r.is_a?(Robot)
			@robots << r
			add_body(r)
		end

        def add_landmark(m)
            raise "expecting a #{Landmark}, which #{m} is not" unless m.is_a?(Landmark)
			@landmarks << m
			add_body(m)
        end

		def add_waypoint(w)
            raise "expecting a #{Waypoint}, which #{w} is not" unless w.is_a?(Waypoint)
			@waypoints << w
			add_body(w)
        end

		def step(dt)
			@dt = dt
			@bodies.each do |b|
				ppos = b.pos.dup
				b.step(dt)
				npos = b.pos.dup
				if b.pos.x < 0 then
					b.pos.x = 0
				elsif b.pos.x > @width then
					b.pos.x = @width
				end
				if b.pos.y < 0 then
					b.pos.y = 0
				elsif b.pos.y > @height then
					b.pos.y = @height
				end
				if b.pos != npos then
					b.v = (b.pos - ppos).length / dt
				end
			end
			@robots.each do |r|
				r.update_sensors
				r.controller_run
			end
		end

		def close_figure
			@figure.close if @figure
			@figure = nil
		end

		def inspect
			"#<#{self.class}>"
		end

		private

		def add_body(b)
			raise "expecting a #{Body}, which #{b} is not" unless b.is_a?(Body)
			b.world = self
			@bodies << b
		end

		def open_figure
			return if @figure
			@figure = VIBes::Figure.new 'world'
			@figure.set_size(@width, @height)
			@figure.axis_limits(0..@width, 0..@height)
		end

		###############################################

		@@CURID = 0
		def self.new_ID
			@@CURID += 1
			@@CURID.to_s(16).rjust(8, '0')
		end
	end
end