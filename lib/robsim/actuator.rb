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
	class Actuator
		def initialize
			@cmd = 0.0
		end

		def cmd
			@cmd
		end

		def cmd=(v)
			@cmd = v.to_f
		end

		def inspect
			"#<#{self.class}>"
		end
	end

	class Accelerator < Actuator
		def initialize
			super()
		end
	end

	class Rotator < Actuator
		def initialize
			super()
		end
	end
end


