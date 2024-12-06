pub type Position =
  #(Int, Int)

pub fn mult_position(position: Position, number: Int) -> Position {
  let #(x, y) = position
  #(x * number, y * number)
}

pub fn add_position(position1: Position, position2: Position) -> Position {
  let #(x1, y1) = position1
  let #(x2, y2) = position2
  #(x1 + x2, y1 + y2)
}
