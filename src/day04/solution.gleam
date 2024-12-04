import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

type Position =
  #(Int, Int)

type Letter =
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

fn get_letter(list: List(Letter), pos: Position) -> Option(String) {
  case
    list.find(list, fn(item) {
      let #(pos1, letter) = item
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

fn is_x(letter: Letter) -> Bool {
  let #(_, l) = letter
  l == "X"
}

fn find_xmases(letters: List(Letter), letter: Letter) -> Int {
  let #(pos, _) = letter
  directions()
  |> list.count(fn(dir) {
    get_letter(letters, add_position(pos, dir)) == Some("M")
    && get_letter(letters, add_position(pos, mult_position(dir, 2)))
    == Some("A")
    && get_letter(letters, add_position(pos, mult_position(dir, 3)))
    == Some("S")
  })
}

pub fn run(input) {
  let empty_list: List(Letter) = []

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
          let list = case letter {
            "X" -> list.prepend(acc2, #(#(x, y), "X"))
            "M" -> list.prepend(acc2, #(#(x, y), "M"))
            "A" -> list.prepend(acc2, #(#(x, y), "A"))
            "S" -> list.prepend(acc2, #(#(x, y), "S"))
            _ -> acc2
          }
          #(x + 1, list)
        })

      #(y + 1, result)
    })

//  list.each(letters, io.debug)

  letters
  |> list.filter(is_x)
  |> list.fold(0, fn(acc, item) { acc + find_xmases(letters, item) })
  |> io.debug()

  Nil
}
