# 親分エネミー
class BossEnemy
  attr_accessor :mesh, :expired

  # object を mesh のエイリアスとして定義
  def object
    mesh
  end

  def initialize(x: 0.0, y: 0.0, z: 0.0, scene: nil)
    pos = Mittsu::Vector3.new(x, y, z)

    self.mesh = MeshFactory.create_boss_enemy
    mesh.position = pos
    self.expired = false
  end

  def position
    mesh.position
  end

  def play
    mesh.rotation.x += (Math::PI / 180.0) * (45.0 / 60.0)
    mesh.rotation.y += (Math::PI / 180.0) * (45.0 / 60.0)
    move_randomly
  end

  def move_randomly
    dx = rand(3)
    dy = rand(3)

    case dx
    when 0
      # 何もしない
    when 1
      mesh.position.x += 1
    when 2
      mesh.position.x -= 1
    end

    case dy
    when 0
      # 何もしない
    when 1
      mesh.position.y += 1
    when 2
      mesh.position.y -= 1
    end
  end
end
