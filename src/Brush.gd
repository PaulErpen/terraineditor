extends Object

class_name Brush

enum BrushType {
    Linear,
    Round,
    Gaussian
}

static func compute_influence(current_pos: Vector2, brush_pos: Vector2, brush_radius: float, brush_type: BrushType) -> float:
    var distance: float = current_pos.distance_to(brush_pos)
    if distance > brush_radius:
        return 0.0

    match brush_type:
        BrushType.Linear:
            return max(0.01, 1.0 - (distance / brush_radius))
        BrushType.Round:
            return 1.0 - (distance / brush_radius) ** 2
        BrushType.Gaussian:
            return exp(-(distance * 0.4) ** 2) / 1.05
    
    return 0.0