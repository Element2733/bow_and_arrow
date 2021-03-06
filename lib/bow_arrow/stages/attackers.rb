# Copyright 2009 Wilker Lucio <wilkerlucio@gmail.com>
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module BowArrow
  module Stages
    class Attackers < Base
      include TimerMachine
      
      class << self
        def enemy_class(enemy_class = nil)
          @enemy_class = enemy_class unless enemy_class.nil?
          @enemy_class
        end
      end
      
      def start_level
        #setup overwrite these variables
        @enemies_left = 0
        @frequency = 0.0
        @frequency_speed = 0.0
        
        attacker_setup if respond_to? :attacker_setup
        
        @enemies_left += ((@game.level - 1) * @enemies_left * 0.5).round
        @frequency += (@game.level - 1) * @frequency * 0.5
        @frequency_speed += (@game.level - 1) * @frequency_speed * 0.5
        
        add_timer 3, 0 do
          @frequency += @frequency_speed if current_state == :running
        end
        
        add_timer 0.04, 0 do
          if current_state == :running and rand < @frequency
            create_enemy
          end
        end
      end
      
      def create_enemy
        return if @enemies_left == 0
        
        @enemies_left -= 1
        
        enemy = self.class.enemy_class.new app
        enemy.x = app.width
        enemy.y = rand(480 - enemy.height)
        enemy.speed = @game.level * enemy.speed + ((@game.level - 1) * enemy.speed * 0.5)
        
        customize_enemy enemy if respond_to? :customize_enemy
        
        @enemies << enemy
      end
      
      def win?
        @enemies_left == 0 and @enemies.length == 0
      end
    end
  end
end