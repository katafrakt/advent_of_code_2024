import gleam/int
import gleam/io
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/string
import utils/utils

type Report =
  List(Int)

type ListType {
  UnknownList(Report)
  IncreasingList(Report)
  DecreasingList(Report)
  InvalidList
}

fn process_element(list, element) {
  case list {
    InvalidList -> InvalidList
    UnknownList([]) -> UnknownList([element])
    UnknownList([hd, ..rest]) -> {
      case int.compare(element, hd) {
        Lt -> {
          case hd - element <= 3 {
            True -> DecreasingList([element, ..[hd, ..rest]])
            False -> InvalidList
          }
        }
        Gt -> {
          case element - hd <= 3 {
            True -> IncreasingList([element, ..[hd, ..rest]])
            False -> InvalidList
          }
        }
        Eq -> InvalidList
      }
    }
    DecreasingList([hd, ..rest]) -> {
      case hd > element && hd - element <= 3 {
        True -> DecreasingList([element, ..[hd, ..rest]])
        False -> InvalidList
      }
    }
    IncreasingList([hd, ..rest]) -> {
      case hd < element && element - hd <= 3 {
        True -> IncreasingList([element, ..[hd, ..rest]])
        False -> InvalidList
      }
    }
    _ -> panic as "Invalid list"
  }
}

fn is_valid(list) {
  let result = list.fold(list, UnknownList([]), process_element)

  case result {
    InvalidList -> False
    UnknownList(_) -> False
    _ -> True
  }
}

pub fn run(input: String) {
  let reports =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      string.split(line, " ")
      |> list.map(fn(x) { utils.str_to_int(x) })
    })

  // part 1
  reports
  |> list.count(fn(x) { is_valid(x) })
  |> io.debug

  // part 2
  reports
  |> list.count(fn(x) {
    case is_valid(x) {
      True -> True
      False -> {
        list.combinations(x, list.length(x) - 1)
        |> list.any(is_valid)
      }
    }
  })
  |> io.debug

  Nil
}
