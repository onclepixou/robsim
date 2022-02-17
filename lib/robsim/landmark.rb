# Copyright (C) 2022  Pierre Filiol  <pierre.filiol@netc.fr>
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
	class Landmark < Body
		@@landmark_counter = 1

        attr_accessor :landmark_num #@return [Integer]
		attr_accessor :length       #@return [Float]
		attr_accessor :color        #@return [string]

		def initialize(x, y)
			super()
            set_pos(x,y)
			@length = 10
			@color = 'k[g]'
			@landmark_num = @@landmark_counter
			@@landmark_counter += 1
		end

		def step(dt)
		end

		def draw(figure)
			figure.remove_object @id
            figure.draw_point(@pos.x, pos.y, radius: @length, color: @color, name: @id)
		end

		def inspect
			"#<#{self.class}>"
		end
	end
end

