import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

type Position =
  #(Int, Int)

fn mult_position(position: Position, number: Int) -> Position {
  let #(x, y) = position
  #(x * number, y * number)
}

fn add_position(position1: Position, position2: Position) -> Position {
  let #(x1, y1) = position1
  let #(x2, y2) = position2
  #(x1 + x2, y1 + y2)
}

fn directions() {
  [#(0, 1), #(0, -1), #(1, 1), #(1, 0), #(1, -1), #(-1, 0), #(-1, 1), #(-1, -1)]
}

fn get_letter(list: Dict(Position, String), pos: Position) -> Option(String) {
  case dict.get(list, pos) {
    Ok(l) -> Some(l)
    Error(_) -> None
  }
}

fn find_xmases(letters: Dict(Position, String), pos: Position) -> Int {
  directions()
  |> list.count(fn(dir) {
    get_letter(letters, add_position(pos, dir)) == Some("M")
    && get_letter(letters, add_position(pos, mult_position(dir, 2)))
    == Some("A")
    && get_letter(letters, add_position(pos, mult_position(dir, 3)))
    == Some("S")
  })
}

fn find_x_mases(letters: Dict(Position, String), pos: Position) -> Int {
  let is_tr_dl = case get_letter(letters, add_position(pos, #(-1, -1))) {
    Some("M") -> get_letter(letters, add_position(pos, #(1, 1))) == Some("S")
    Some("S") -> get_letter(letters, add_position(pos, #(1, 1))) == Some("M")
    _ -> False
  }
  let is_tl_dr = case get_letter(letters, add_position(pos, #(-1, 1))) {
    Some("M") -> get_letter(letters, add_position(pos, #(1, -1))) == Some("S")
    Some("S") -> get_letter(letters, add_position(pos, #(1, -1))) == Some("M")
    _ -> False
  }

  case is_tr_dl && is_tl_dr {
    True -> 1
    False -> 0
  }
}

pub fn run(input) {
  let empty_letters: Dict(Position, String) = dict.from_list([])

  let #(_, letters) =
    input
    |> string.split("\n")
    |> list.fold(#(0, empty_letters), fn(acc, line) {
      let #(y, acc) = acc
      let #(_, result) =
        line
        |> string.to_graphemes()
        |> list.fold(#(0, acc), fn(acc2, letter) {
          let #(x, acc2) = acc2
          #(x + 1, dict.insert(acc2, #(x, y), letter))
        })

      #(y + 1, result)
    })

  // part 1
  letters
  |> dict.filter(fn(_, v) { v == "X" })
  |> dict.fold(0, fn(acc, pos, _) { acc + find_xmases(letters, pos) })
  |> io.debug()

  // part 2
  letters
  |> dict.filter(fn(_, v) { v == "A" })
  |> dict.fold(0, fn(acc, pos, _) { acc + find_x_mases(letters, pos) })
  |> io.debug()

  Nil
}
