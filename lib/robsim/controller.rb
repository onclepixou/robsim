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

require 'fiber'

module Robsim
	class Controller

		attr_reader   :id     #@return [String]

		def initialize()
			@id = World.new_ID
		end

		def controller_set_robot(r)
			raise "This instance of #{Controller} was already assigned a robot" if @controller_robot
			raise "expecting a #{Robot}, which #{r} is not" unless r.is_a?(Robot)
			@controller_robot = r
		end

		def controller_run
			controller_fiber.resume
			self
		end

		def controller_alive?
			return false unless @controller_fiber
			controller_fiber.alive?
		end

		def controller_restart!
			@controller_fiber = nil
			self
		end

		def inspect
			"#<#{self.class}>"
		end

		def draw(figure)
			raise "you must derive from the #{Controller} class and implement the 'draw()' method"
		end

		private

		def controller_robot
			raise "This #{Controller} has not been assigned to a #{Robot}" unless @controller_robot
			@controller_robot
		end

		def controller_fiber
			if @controller_fiber.nil? then
				raise "Your controller must derive from the #{Controller} class and implement the #{Controller}#main method" unless respond_to?(:main)
				@controller_fiber = Fiber.new{ main() }
			end
			@controller_fiber
		end

		def wait_next_step
			Fiber.yield
		end

		def sensor_changed?(sensor_name)
			s = controller_robot.sensors[sensor_name.to_sym]
			raise "No sensor name \"#{sensor_name}\" found" if s.nil?
			s.value_changed?
		end

		def sensor_value(sensor_name)
			s = controller_robot.sensors[sensor_name.to_sym]
			raise "No sensor name \"#{sensor_name}\" found" if s.nil?
			s.value
		end

		def sensor_read(sensor_name)
			s = controller_robot.sensors[sensor_name.to_sym]
			raise "No sensor name \"#{sensor_name}\" found" if s.nil?
			s.read
		end

		def time
			controller_robot.world.simulator.time
		end

		def wait(t)
			wake_up_time = time + t.to_f
			wait_next_step until time >= wake_up_time
		end

		def sensors
			controller_robot.sensors
		end

		def sensor(name)
			controller_robot.sensors[name.to_sym].value
		end

		def accelerator
			controller_robot.accelerator
		end

		def rotator
			controller_robot.rotator
		end

		def acceleration
			controller_robot.accelerator.cmd
		end

		def acceleration=(v)
			controller_robot.accelerator.cmd = v
		end

		def rotation
			controller_robot.rotator.cmd
		end

		def rotation=(v)
			controller_robot.rotator.cmd = v
		end
	end
end

