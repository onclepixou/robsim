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
	class Simulator
		attr_reader :world #@return [World]
		attr_reader :time  #@return [Float]

		def initialize(width: 1280, height: 720)
			@world = World.new(width, height)
			@world.simulator = self
		end

		def simulate(steps_per_second: 30, print_cpu_load: false)
			dt = (1.0 / steps_per_second).abs
			i = 0
			@time = 0.0
			puts 'Simulation started'
			begin
				tick_real = Time.now
				cpu_time = 0.0
				loop do
					t = Time.now
					i += 1
					@time = i*dt
					@world.step(dt)
					@world.draw

					tnow = Time.now
					if print_cpu_load then
						cpu_time += tnow - t
						rt = tnow - tick_real
						if rt >= 5 then
							l = cpu_time * 100.0 / (tnow - tick_real)
							puts "[Simulator] @#{@time.round(1)}: load = #{l.round(1)}%"
							tick_real = tnow
							cpu_time = 0.0
						end
					end
					sleep_time = dt - (tnow - t)
					sleep(sleep_time) if sleep_time > 0
				end
			rescue Interrupt
				puts "\b\bSimulation stopped at time #{@time.round(3)} s"
			end
			@world.close_figure
		end

		def inspect
			"#<#{self.class}>"
		end

	end
end

