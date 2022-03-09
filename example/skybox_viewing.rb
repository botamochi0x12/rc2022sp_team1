require 'mittsu'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ASPECT = SCREEN_WIDTH.to_f / SCREEN_HEIGHT.to_f

scene = Mittsu::Scene.new
skybox_scene = Mittsu::Scene.new
camera = Mittsu::PerspectiveCamera.new(75.0, ASPECT, 0.1, 1000.0)
skybox_camera = Mittsu::PerspectiveCamera.new(75.0, ASPECT, 1.0, 100.0)

renderer = Mittsu::OpenGLRenderer.new width: SCREEN_WIDTH, height: SCREEN_HEIGHT, title: 'Skymap Viewing'
renderer.auto_clear = false
renderer.shadow_map_enabled = true
renderer.shadow_map_type = Mittsu::PCFSoftShadowMap

cube_map_texture = Mittsu::ImageUtils.load_texture_cube(
    [ 'rt', 'lf', 'up', 'dn', 'bk', 'ft' ].map { |path|
        File.join File.dirname(__FILE__), "../images/desert.png"
    }
)

shader = Mittsu::ShaderLib[:cube]
shader.uniforms['tCube'].value = cube_map_texture

skybox_material = Mittsu::ShaderMaterial.new({
    fragment_shader: shader.fragment_shader,
    vertex_shader: shader.vertex_shader,
    uniforms: shader.uniforms,
    depth_write: false,
    side: Mittsu::BackSide
}
)

skybox = Mittsu::Mesh.new(Mittsu::BoxGeometry.new(100, 100, 100), skybox_material)
skybox_scene.add(skybox)

def set_repeat(tex)
    tex.wrap_s = Mittsu::RepeatWrapping
    tex.wrap_t = Mittsu::RepeatWrapping
    tex.repeat.set(1000, 1000)
end

floor = Mittsu::Mesh.new(
    Mittsu::BoxGeometry.new(1.0, 1.0, 1.0),
    Mittsu::MeshPhongMaterial.new(
        map: Mittsu::ImageUtils.load_texture(File.join File.dirname(__FILE__), '../images/desert.png').tap { |t| set_repeat(t) },
        normal_map: Mittsu::ImageUtils.load_texture(File.join File.dirname(__FILE__), '../images/desert-normal.png').tap { |t| set_repeat(t) }
    )
)
floor.scale.set(10000.0, 10.0, 10000.0)
floor.position.y = -5.0
scene.add(floor)

sunlight = Mittsu::HemisphereLight.new(0xd3c0e8, 0xd7ad7e, 0.7)
scene.add(sunlight)

light = Mittsu::SpotLight.new(0xffffff, 1.0)
light.position.set(0.0, 30.0, -30.0)

light.cast_shadow = true
light.shadow_darkness = 0.5

light.shadow_map_width = 2048
light.shadow_map_height = 2048

light.shadow_camera_near = 1.0
light.shadow_camera_far = 100.0
light.shadow_camera_fov = 60.0

light.shadow_camera_visible = false
scene.add(light)

camera.position.z = -3.0
camera.position.y = 0.6
camera.rotation.y = Math::PI
# camera.rotation.x = Math::PI/12.0

renderer.window.on_resize do |width, height|
    renderer.set_viewport(0, 0, width, height)
    camera.aspect = skybox_camera.aspect = width.to_f / height.to_f
    camera.update_projection_matrix
    skybox_camera.update_projection_matrix
end

renderer.window.run do

    floor.position.z -= 0.1

    camera.rotate_x(+0.1) if renderer.window.key_down?(GLFW_KEY_X)
    camera.rotate_x(-0.1) if renderer.window.key_down?(GLFW_KEY_W)
    camera.rotate_y(+0.1) if renderer.window.key_down?(GLFW_KEY_RIGHT)
    camera.rotate_y(-0.1) if renderer.window.key_down?(GLFW_KEY_LEFT)
    camera.rotate_z(+0.1) if renderer.window.key_down?(GLFW_KEY_A)
    camera.rotate_z(-0.1) if renderer.window.key_down?(GLFW_KEY_D)

    skybox_camera.quaternion.copy(camera.get_world_quaternion)

    renderer.clear
    renderer.render(skybox_scene, skybox_camera);
    renderer.clear_depth
    renderer.render(scene, camera)
end
