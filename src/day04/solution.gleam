import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

type Position =
  #(Int, Int)

type Item =
  #(Position, String)

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

fn get_letter(list: List(Item), pos: Position) -> Option(String) {
  case
    list.find(list, fn(item) {
      let #(pos1, _) = item
      pos1 == pos
    })
  {
    Ok(item) -> {
      let #(_, l) = item
      Some(l)
    }
    Error(_) -> None
  }
}

fn is_letter(item: Item, letter: String) -> Bool {
  let #(_, l) = item
  l == letter
}

fn find_xmases(letters: List(Item), item: Item) -> Int {
  let #(pos, _) = item

  directions()
  |> list.count(fn(dir) {
    get_letter(letters, add_position(pos, dir)) == Some("M")
    && get_letter(letters, add_position(pos, mult_position(dir, 2)))
    == Some("A")
    && get_letter(letters, add_position(pos, mult_position(dir, 3)))
    == Some("S")
  })
}

fn find_x_mases(letters: List(Item), item: Item) -> Int {
  let #(pos, _) = item
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
  let empty_list: List(Item) = []

  let #(_, letters) =
    input
    |> string.split("\n")
    |> list.fold(#(0, empty_list), fn(acc, line) {
      let #(y, acc) = acc
      let #(_, result) =
        line
        |> string.to_graphemes()
        |> list.fold(#(0, acc), fn(acc2, letter) {
          let #(x, acc2) = acc2
          let list = list.prepend(acc2, #(#(x, y), letter))
          #(x + 1, list)
        })

      #(y + 1, result)
    })

  // part 1
  letters
  |> list.filter(fn(i) { is_letter(i, "X") })
  |> list.fold(0, fn(acc, item) { acc + find_xmases(letters, item) })
  |> io.debug()

  // part 2
  letters
  |> list.filter(fn(i) { is_letter(i, "A") })
  |> list.fold(0, fn(acc, item) { acc + find_x_mases(letters, item) })
  |> io.debug()

  Nil
}
