# 親分エネミー
class BossEnemy
    attr_accessor :object, :expired, :rotation, :mesh

    def initialize(x: nil, y: nil, z: nil, scene: nil, object: nil)
        x ||= rand(10) / 10.0 - 0.5
        #y ||= rand(10) / 10.0 + 1
        #z ||= rand(10) / 10.0 + 3

        self.object = object

        pos = Mittsu::Vector3.new(x, 40, -100)

        self.object.position = pos
        self.expired = false

    end

    def position
        self.object.position
    end

    def play
        dx = rand(3)
        dy = rand(3)
        self.object.rotation.x += 0.1
        self.object.rotation.y += 0.1

        case dx
        when 1
            self.object.position.x += 0
        when 2
            self.object.position.x -= 0
        end

        case dy
        when 1
            self.object.position.y += 0
        when 2
            self.object.position.y -= 0
        end
    end
end
