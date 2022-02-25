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
	class Body
		attr_accessor :pos #@return [Vec2] x, y position
		attr_accessor :ang #@return [Float] orientation, in radians
		attr_accessor :v   #@return [Float] linear speed

		attr_reader   :world  #@return [World]
		attr_reader   :id     #@return [String]

		def initialize()
			@pos = Vec2.new(0.0, 0.0)
			@ang = Math::PI/2
			@v = 0.0

			@world = nil
			@id = World.new_ID
		end

		def set_pos(x, y)
			@pos.x = x
			@pos.y = y
			@pos
		end

		def set_speed(speed)
			@v = speed
		end

		def set_angle(a)
			@ang = a.to_f
		end

		def set_angle_deg(a)
			@ang = a.to_f * Math::PI / 180
		end

		def step(dt)
			raise "you must derive from the #{Body} class and implement the 'step(dt)' method"
		end

		def draw(figure)
			raise "you must derive from the #{Body} class and implement the 'draw()' method"
		end

		def inspect
			"#<#{self.class}>"
		end

		def world=(w)
			raise "expecting a #{World}, which #{w} is not" unless w.is_a?(World)
			raise "attribute :world already set for #{self}" unless @world.nil?
			@world = w
		end
	end
end

