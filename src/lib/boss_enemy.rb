# 親分エネミー
class BossEnemy
    attr_accessor :object, :expired, :rotation, :mesh

    def initialize(x: 0.0, y: 40.0, z: -100.0, scene: nil, object: nil)
        self.object = object

        pos = Mittsu::Vector3.new(x, y, z)

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
