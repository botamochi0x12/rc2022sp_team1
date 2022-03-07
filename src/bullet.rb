class Bullet
  attr_accessor :mesh

  def initialize(x, y, z)
    @mesh = Mittsu::Mesh.new(
      Mittsu::BoxGeometry.new(0.2, 0.2, 0.2),
      Mittsu::MeshBasicMaterial.new(color: 0x00ff00)
    )
    @mesh.position.set(x, y, z)
  end

  def update
    @mesh.position.z -= 0.2
  end
end