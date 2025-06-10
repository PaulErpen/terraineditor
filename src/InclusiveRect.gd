extends Object

class_name InclusiveRect

var position: Vector2
var size: Vector2

static func create(_position: Vector2, _size: Vector2) -> InclusiveRect:
    var rect = InclusiveRect.new()
    rect.position = _position
    rect.size = _size
    return rect

func intersection(other: InclusiveRect) -> InclusiveRect:
    var new_position = Vector2(
        max(self.position.x, other.position.x),
        max(self.position.y, other.position.y)
    )
    var new_size = Vector2(
        min(self.position.x + self.size.x, other.position.x + other.size.x) - new_position.x,
        min(self.position.y + self.size.y, other.position.y + other.size.y) - new_position.y
    )
    
    return InclusiveRect.create(new_position, new_size)