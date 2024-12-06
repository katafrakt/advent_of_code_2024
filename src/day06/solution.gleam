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

type GuardPosition {
  GuardPosition(position: Position, direction: Direction)
}

type Lab {
  Lab(
    width: Int,
    height: Int,
    obstacles: List(Position),
    guard_position: GuardPosition,
    guard_direction: Direction,
    past_positions: List(GuardPosition),
  )
}

type MovingEnd {
  LeftLab(Lab)
  Loop(Lab)
}

fn build_lab(input) {
  let lines = string.split(input, "\n") |> list.filter(fn(l) { l != "" })
  let lab =
    Lab(
      width: 0,
      height: list.length(lines),
      obstacles: [],
      guard_position: GuardPosition(#(0, 0), Up),
      guard_direction: Up,
      past_positions: [],
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

fn put_guard(lab: Lab, position: Position) -> Lab {
  let guard_pos = GuardPosition(position, lab.guard_direction)
  Lab(..lab, guard_position: guard_pos, past_positions: [guard_pos])
}

fn keep_moving_guard(lab: Lab) -> MovingEnd {
  let lab = move_guard(lab)
  let #(guard_x, guard_y) = lab.guard_position.position

  let positions_to_check = case lab.past_positions {
    [_, ..tail] -> tail
    [] -> []
  }

  case
    guard_x >= lab.width || guard_x < 0 || guard_y >= lab.height || guard_y < 0
  {
    True -> LeftLab(lab)
    False -> {
      case list.contains(positions_to_check, lab.guard_position) {
        True -> Loop(lab)
        False -> keep_moving_guard(lab)
      }
    }
  }
}

fn is_obstacle(lab: Lab, position: Position) -> Bool {
  list.contains(lab.obstacles, position)
}

fn move_guard(lab: Lab) -> Lab {
  let candidate_pos =
    direction_to_position(lab.guard_direction)
    |> position.add_position(lab.guard_position.position)

  case is_obstacle(lab, candidate_pos) {
    True -> {
      let new_dir = turn(lab.guard_direction)
      let new_pos = GuardPosition(..lab.guard_position, direction: new_dir)
      Lab(
        ..lab,
        guard_direction: turn(lab.guard_direction),
        guard_position: new_pos,
        past_positions: [new_pos, ..lab.past_positions],
      )
    }
    False -> {
      let pos = GuardPosition(candidate_pos, lab.guard_direction)
      Lab(
        ..lab,
        guard_position: pos,
        past_positions: [pos, ..lab.past_positions],
      )
    }
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

fn free_positions(lab: Lab) -> List(Position) {
  do_free_positions(lab, [], 0, 0)
}

fn do_free_positions(
  lab: Lab,
  free: List(Position),
  x: Int,
  y: Int,
) -> List(Position) {
  let pos = #(x, y)
  let new_free = case
    is_obstacle(lab, pos) || pos == lab.guard_position.position
  {
    True -> free
    False -> [pos, ..free]
  }

  case x + 1 >= lab.width {
    True -> {
      case y + 1 >= lab.height {
        True -> new_free
        False -> do_free_positions(lab, new_free, 0, y + 1)
      }
    }
    False -> do_free_positions(lab, new_free, x + 1, y)
  }
}

pub fn run(input) {
  let original_lab = build_lab(input)
  let lab = case keep_moving_guard(original_lab) {
    LeftLab(lab) -> lab
    _ -> panic as "Guard looped"
  }

  // part 1
  let visited_positions =
    lab.past_positions
    |> list.map(fn(gp) { gp.position })
    |> list.unique()

  // last position is outside of lab
  io.debug(list.length(visited_positions) - 1)

  // part 2
  free_positions(original_lab)
  |> list.filter(fn(pos) { list.contains(visited_positions, pos) })
  |> list.count(fn(pos) {
    let lab = add_obstacle(original_lab, pos)
    case keep_moving_guard(lab) {
      Loop(_) -> True
      _ -> False
    }
  })
  |> io.debug()

  Nil
}
