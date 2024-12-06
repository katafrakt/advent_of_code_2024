import gleam/io
import gleam/list
import gleam/string
import utils/position.{type Position}

type Direction {
  Up
  Down
  Left
  Right
}

fn direction_to_position(dir) {
  case dir {
    Up -> #(0, -1)
    Down -> #(0, 1)
    Left -> #(-1, 0)
    Right -> #(1, 0)
  }
}

type Lab {
  Lab(
    width: Int,
    height: Int,
    obstacles: List(Position),
    guard_position: Position,
    guard_direction: Direction,
    visited_positions: List(Position),
  )
}

fn build_lab(input) {
  let lines = string.split(input, "\n") |> list.filter(fn(l) { l != "" })
  let lab =
    Lab(
      width: 0,
      height: list.length(lines),
      obstacles: [],
      guard_position: #(0, 0),
      guard_direction: Up,
      visited_positions: [],
    )

  let #(_, lab) =
    list.fold(lines, #(0, lab), fn(acc, line) {
      let #(idx, lab) = acc
      let chars = string.split(line, "")
      let #(_, lab) =
        list.fold(chars, #(0, lab), fn(acc, char) {
          let #(idx2, lab) = acc
          let lab = Lab(..lab, width: list.length(chars))
          let position = #(idx2, idx)
          let lab = case char {
            "#" -> add_obstacle(lab, position)
            "^" -> put_guard(lab, position)
            _ -> lab
          }

          #(idx2 + 1, lab)
        })
      #(idx + 1, lab)
    })

  lab
}

fn add_obstacle(lab, position) {
  Lab(..lab, obstacles: [position, ..lab.obstacles])
}

fn put_guard(lab, position) {
  Lab(..lab, guard_position: position, visited_positions: [position])
}

fn keep_moving_guard(lab) {
  let lab = move_guard(lab)
  let #(guard_x, guard_y) = lab.guard_position

  case
    guard_x >= lab.width || guard_x < 0 || guard_y >= lab.height || guard_y < 0
  {
    True -> lab
    False -> keep_moving_guard(lab)
  }
}

fn is_obstacle(lab: Lab, position: Position) -> Bool {
  list.contains(lab.obstacles, position)
}

fn move_guard(lab: Lab) -> Lab {
  let candidate_pos =
    direction_to_position(lab.guard_direction)
    |> position.add_position(lab.guard_position)

  case is_obstacle(lab, candidate_pos) {
    True -> Lab(..lab, guard_direction: turn(lab.guard_direction))
    False ->
      Lab(
        ..lab,
        guard_position: candidate_pos,
        visited_positions: [candidate_pos, ..lab.visited_positions],
      )
  }
}

fn turn(dir) {
  case dir {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

pub fn run(input) {
  let lab = build_lab(input)
  let lab = keep_moving_guard(lab)

  let positions =
    lab.visited_positions
    |> list.unique()
    |> list.length()
  // last position is outside of lab
  io.debug(positions - 1)

  Nil
}
