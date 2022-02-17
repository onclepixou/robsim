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
	class Vec2
		attr_reader :x, :y

		def initialize(x = nil, y = nil)
			if x.nil? then
				@x = 0.0
				@y = 0.0
			elsif y.nil? then
				if x.is_a(Vec2) then
					@x = x.x
					@y = x.y
				else
					@x = x.to_f
					@y = 0.0
				end
			else
				@x = x.to_f
				@y = y.to_f
			end
		end

		def self.[](*xy)
			Vec2.new(*xy)
		end

		def ==(o)
			return false unless o.kind_of? Vec2
			(@x == o.x and @y == o.y)
		end

		def !=(o)
			return true unless o.kind_of? Vec2
			(@x != o.x or @y != o.y)
		end

		def to_a
			[@x, @y]
		end

		def x=(v)
			@x = v.to_f
		end

		def y=(v)
			@y = v.to_f
		end

		def length
			v = Math.sqrt(@x*@x+@y*@y)
			v = 0.0 unless v.finite?
			v
		end

		def coerce(n)
			[Vec2.new(n, n), self]
		end

		def -@
			Vec2.new(-@x, -@y)
		end

		def +(v)
			if v.kind_of?(Vec2) then
				Vec2.new(@x+v.x, @y+v.y)
			else
				Vec2.new(@x+v, @y+v)
			end
		end

		def -(v)
			if v.kind_of?(Vec2) then
				Vec2.new(@x-v.x, @y-v.y)
			else
				Vec2.new(@x-v, @y-v)
			end
		end

		def *(v)
			if v.kind_of?(Vec2) then
				Vec2.new(@x*v.x, @y*v.y)
			else
				Vec2.new(@x*v, @y*v)
			end
		end

		def /(v)
			if v.kind_of?(Vec2) then
				Vec2.new(@x/v.x, @y/v.y)
			else
				Vec2.new(@x/v, @y/v)
			end
		end

		def dot_prod(v2)
			@x * v2.x + @y * v2.y
		end

		def angle
			a = Math.atan2(@y, @x)
			a = 0.0 unless a.finite?
			a
		end
	end
end