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

pub fn list_at(lst: List(a), index: Int) -> a {
  let val =
    list.index_map(lst, fn(v, i) {
      case i == index {
        True -> Some(v)
        False -> None
      }
    })
    |> list.find(option.is_some)

  case val {
    Ok(Some(i)) -> i
    _ -> panic as "No value at index #{i}"
  }
}

pub fn list_remove(lst: List(a), elem: a) -> List(a) {
  case list.split_while(lst, fn(x) { x != elem }) {
    #(sublist1, [_, ..sublist2]) -> list.append(sublist1, sublist2)
    _ -> lst
  }
}
