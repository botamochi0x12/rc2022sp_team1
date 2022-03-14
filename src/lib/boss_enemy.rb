# 親分エネミー
class BossEnemy
  attr_accessor :object, :expired, :rotation

  # mesh をプロパティとして定義
  def mesh
    object
  end

  def initialize(x: 0.0, y: 40.0, z: -100.0, scene: nil, object: nil)
    pos = Mittsu::Vector3.new(x, y, z)

    self.object = object
    self.object.position = pos
    self.expired = false
  end

  def position
    object.position
  end

  def play
    object.rotation.x += (Math::PI / 180.0) * (45.0 / 60.0)
    object.rotation.y += (Math::PI / 180.0) * (45.0 / 60.0)
    move_randomly
  end

  def move_randomly
    dx = rand(3)
    dy = rand(3)

    case dx
    when 0
      # 何もしない
    when 1
      object.position.x += 1
    when 2
      object.position.x -= 1
    end

    case dy
    when 0
      # 何もしない
    when 1
      object.position.y += 1
    when 2
      object.position.y -= 1
    end
  end
end
