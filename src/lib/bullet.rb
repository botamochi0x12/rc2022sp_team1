# 弾丸モデル
class Bullet
  attr_accessor :mesh, :expired

  SPEED = -0.2 # 弾丸の速度
  FRAME_COUNT_UPPER_LIMIT = 3 * 60

  # 初期化
  # 進行方向を表す単位ベクトルを受領する
  def initialize(forward_vector)
    self.mesh = MeshFactory.create_bullet(r: 0.07)
    mesh.rotation.z = -0.25 * Math::PI
    @forward_vector = forward_vector
    @forwarded_frame_count = 0 # 何フレーム分進行したかを記憶するカウンタ
    self.expired = false
  end

  # メッシュの現在位置を返す
  def position
    mesh.position
  end

  # １フレーム分の進行処理
  def play
    # オブジェクト生成時に渡された進行方向に向けて、単位ベクトル分だけ進む
    mesh.position.add(@forward_vector)

    @forwarded_frame_count += 1

    # 進行フレーム数が上限に達したら消滅フラグを立てる
    self.expired = true if @forwarded_frame_count > FRAME_COUNT_UPPER_LIMIT
  end
end
