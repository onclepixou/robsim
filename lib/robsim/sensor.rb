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

module Robsim
	class Sensor
		attr_reader   :name  #@return [Symbol]
		attr_reader   :robot #@return [Robot,nil]

		def initialize(name)
			@name = name.to_sym
			@robot = nil
			@value = nil
			@value_changed = false
		end

		def robot=(r)
			raise "expecting a #{Robot}, which #{r} is not" unless r.is_a?(Robot)
			raise "attribute :robot allready set for #{self}" unless @robot.nil?
			@robot = r
		end

		def value
			@value_changed = false
			@value
		end

		def value=(v)
			if @value != v then
				@value = v
				@value_changed = true
			end
		end

		def value_changed?
			@value_changed
		end

		def read
			ch = value_changed?
			v = value
			return v, ch
		end

		def update
			raise "you must derive from the #{Sensor} class and implement the 'update()' method"
		end

		def inspect
			"#<#{self.class}>"
		end
	end

	class GPS < Sensor
		def initialize
			super(:GPS)
		end

		def update
			self.value = [robot.pos.x, robot.pos.y]
		end
	end

	class Speedometer < Sensor
		def initialize
			super(:speedometer)
		end

		def update
			self.value = robot.v
		end
	end

	class Compass < Sensor
		def initialize
			super(:compass)
		end

		def update
			self.value = ((3*Math::PI/2 - robot.ang) % (2*Math::PI)) - Math::PI
		end
	end

	class Odemeter < Sensor
		def initialize 
			super(:odometer)
			@acc = 0.0
		end

		def update
			@last_pos = Vec2.new(robot.pos) unless @last_pos
			acc += (robot.pos - @last_pos).length
			@last_pos.x = robot.pos.x
			@last_pos.y = robot.pos.y
			self.value = acc
		end
	end

	class Accelerometer < Sensor
		def initialize
			super(:accelerometer)
		end

		def update
			@last_pos = Vec2.new(robot.pos) unless @last_pos
			v = (robot.pos - @last_pos).length / robot.world.dt
			@last_pos.x = robot.pos.x
			@last_pos.y = robot.pos.y
			@last_v = v unless @last_v
			a = (v - @last_v) / robot.world.dt
			@last_v = v
			self.value = a
		end
	end

	class Gyroscope < Sensor
		def initialize
			super(:gyroscope)
		end

		def update
			@last_ang = robot.ang unless @last_ang
			g = (((robot.ang - @last_ang + Math::PI) % (2*Math::PI)) - Math::PI) / dt
			@last_ang = robot.ang
			self.value = g
		end
	end

	class BorderDetect < Sensor
		def initialize
			super(:border_detect)
		end

		def update
			p = robot.pos
			x = p.x
			y = p.y
			w = robot.world
			if x < w.width/2 then
				npx = Vec2[0, y]
				ax = Math::PI - robot.ang
			else
				npx = Vec2[w.width, y]
				ax = -robot.ang
			end
			if y < w.height/2 then
				npy = Vec2[x, 0]
				ay = -Math::PI/2 - robot.ang
			else
				npy = Vec2[x, w.height]
				ay = Math::PI/2 - robot.ang
			end

			if (p-npx).length < (p-npy).length then
				np = npx
				a = ax
			else
				np = npy
				a = ay
			end

			robot.np = np
			a = ((a + Math::PI) % (2*Math::PI)) - Math::PI
			self.value = [(np - robot.pos).length, a]
		end
	end
end

