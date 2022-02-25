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

require 'matrix'

module Robsim
	class Robot < Body
		@@robot_counter = 0
		attr_reader :controller  #@return [Controller, nil]
		attr_reader :accelerator #@return [Accelerator]
		attr_reader :rotator     #@return [Rotator]
		attr_reader :sensors     #@return [Hash{Symbol=>Sensor}]

		attr_accessor :length    #@return [Float]
		attr_accessor :color     #@return [string]
		attr_accessor :robot_num #@return [Integer]
		attr_accessor :np

		def initialize()
			super()
			@controller = nil
			@accelerator = Accelerator.new
			@rotator     = Rotator.new
			@sensors = {}
			@length = 20
			@color = 'k[y]'

			@robot_num = @@robot_counter
			@@robot_counter += 1
			@color = 'k[r]' if @robot_num == 0
		end

		def step(dt)

			dxdt = @v*Math.cos(@ang)
			dydt = @v*Math.sin(@ang)
			dadt = rotator.cmd
			dvdt = accelerator.cmd
			@pos.x += dt*dxdt
			@pos.y += dt*dydt
			@ang = (@ang + dt*dadt) % (2*Math::PI)
			@v += dt*dvdt
		end

		def draw(figure)
			figure.remove_object @id
			draw_controller_output(figure)
			figure.draw_vehicle(@pos.to_a, @ang*180/Math::PI, @length, color: @color, name: @id)
		end

		def draw_controller_output(figure)

			if(controller.nil?)
				return
			end

			controller.draw(figure)
		end

		def inspect
			"#<#{self.class}>"
		end

		def add_sensor(sensor)
			sensor = sensor.new if sensor.is_a?(Class)
			raise "expecting a #{Sensor}, which #{sensor} is not" unless sensor.is_a?(Sensor)
			raise "a sensor named #{sensor.name} is allready set for robot #{self}" unless @sensors[sensor.name].nil?
			sensor.robot = self
			@sensors[sensor.name] = sensor
			self
		end

		def update_sensors
			@sensors.each{|n, s| s.update}
			self
		end

		def set_controller(c)
			c = c.new if c.is_a?(Class)
			raise "expecting a #{Controller}, which #{c} is not" unless c.is_a?(Controller)
			@controller = c
			c.controller_set_robot(self)
		end

		def controller_run
			unless @controller then
				@color = 'k[darkGray]'
				return self 
			end
			@controller.controller_run
			@color = 'k[darkGray]' unless @controller.controller_alive?
			self
		end
	end
end

