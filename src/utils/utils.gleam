import gleam/int
import gleam/list
import gleam/option.{None, Some}

// Forcefully convert a string to an integer
pub fn str_to_int(s: String) -> Int {
  case int.parse(s) {
    Ok(i) -> i
    Error(_) -> panic as "Invalid input"
  }
}

pub fn list_at(input, x) {
  let val =
    list.index_map(input, fn(v, i) {
      case i == x {
        True -> Some(v)
        False -> None
      }
    })
    |> list.find(option.is_some)

  case val {
    Ok(i) -> i
    _ -> panic as "No value at index #{i}"
  }
}

pub fn list_remove(l, elem) {
  case list.split_while(l, fn(x) { x != elem }) {
    #(l1, [_, ..l2]) -> list.append(l1, l2)
    _ -> l
  }
}
