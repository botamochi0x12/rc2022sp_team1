
class Enemy
    attr_accessor :object, :expired, :rotation, :mesh

      def initialize(x:nil,y:nil,z:nil,renderer:nil, scene:nil, object:nil)
        #x ||= rand(10) / 10.0 - 0.5
		#y ||= rand(10) / 10.0 + 1
		#z ||= rand(10) / 10.0 + 3

        self.object=object

        pos = Mittsu::Vector3.new(0, 20, -40)

        self.object.position=pos
        self.expired = false

      end

      def position
		self.object.position
      end

      def play
        self.object.rotation.x += 0.1
        self.object.rotation.y += 0.1
        p self.object.position
      end
    end
