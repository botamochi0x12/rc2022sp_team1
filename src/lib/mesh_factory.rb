# メッシュオブジェクトのファクトリー
# ゲーム内に登場するメッシュを生産する役割を一手に引き受ける
class MeshFactory
	# 弾丸の生成
	def self.create_bullet(r: 0.2, div_w: 16, div_h: 16, color: nil, map: nil, normal_map: nil)
		geometry = Mittsu::CylinderGeometry.new(0.07, 0.07, 0.3, 8, 1, false, 0.0, Math::PI * 2.0 )
		material = generate_material(
			:phong, #種類
			nil, #色
			TextureFactory.create_texture_map("earth.png"),
			nil)

		cylinder = Mittsu::Mesh.new(geometry, material)

		geom1 = Mittsu::SphereGeometry.new(r, div_w, div_h, 0.0, Math::PI * 2, 0.0, Math::PI / 2)
		mate1 = generate_material(
			:phong, #種類
			nil, #色
			TextureFactory.create_texture_map("earth.png"),nil)
		harf1 = Mittsu::Mesh.new(geom1, mate1)

		harf1.position.y = 0.15

		geom2 = Mittsu::SphereGeometry.new(r, div_w, div_h, 0.0, Math::PI * 2, 0.0, Math::PI / 2)
		mate2 = generate_material(
			:phong, #種類
			nil, #色
			TextureFactory.create_texture_map("earth.png"),nil)
		harf2 = Mittsu::Mesh.new(geom2, mate2)
		harf2.position.y = -0.15
		harf2.rotation.x = Math::PI

		cylinder.add(harf1,harf2)

	end

	# 敵キャラクタの生成
	def self.create_enemy(r: 0.1, div_w: 16, div_h: 16, color: nil, map: nil, normal_map: nil)
		geometry = Mittsu::SphereGeometry.new(r, div_w, div_h)
		material = generate_material(:basic, color, map, normal_map)
		Mittsu::Mesh.new(geometry, material)
	end

	# 平面パネルの生成
	def self.create_panel(width: 1, height: 1, color: nil, map: nil)
		geometry = Mittsu::PlaneGeometry.new(width, height)
		material = generate_material(:basic, color, map, nil)
		Mittsu::Mesh.new(geometry, material)
	end

	# 地球の生成
	def self.create_earth
		geometry = Mittsu::SphereGeometry.new(1, 64, 64)
		material = generate_material(
			:phong,
			nil,
			TextureFactory.create_texture_map("earth.png"),
			TextureFactory.create_normal_map("earth_normal.png"))
		Mittsu::Mesh.new(geometry, material)
	end

    # プレイヤーが通る管の生成
    def self.create_tube
        geometry = Mittsu::TorusGeometry.new(1, 0.4, 8, 6, Math::PI * 1.1)  # TODO
        material = Mittsu::MeshBasicMaterial.new(color: 0xff0000)  # TODO
        Mittsu::Mesh.new(geometry, material)
    end

	# 汎用マテリアル生成メソッド
	def self.generate_material(type, color, map, normal_map)
		mat = nil
		args = {}
		args[:color] = color if color
		args[:map] = map if map
		args[:normal_map] = normal_map if normal_map
		case type
		when :basic
			mat = Mittsu::MeshBasicMaterial.new(args)

		when :lambert
			mat = Mittsu::MeshLambertMaterial.new(args)

		when :phong
			mat = Mittsu::MeshPhongMaterial.new(args)
		end
		mat
	end
end
