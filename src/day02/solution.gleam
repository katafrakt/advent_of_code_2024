import gleam/int
import gleam/io
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/string
import utils/utils

type ListType {
  UnknownList(List(Int))
  IncreasingList(List(Int))
  DescresingList(List(Int))
  InvalidList
}

fn last(list) {
  case list.last(list) {
    Ok(el) -> el
    Error(_) -> panic as "Empty list"
  }
}

fn is_valid(list) {
  let result =
    list.fold(list, UnknownList([]), fn(acc, elem) {
      case acc {
        InvalidList -> InvalidList
        UnknownList([]) -> UnknownList([elem])
        UnknownList(lst) -> {
          case int.compare(elem, last(lst)) {
            Lt -> {
              case last(lst) - elem <= 3 {
                True -> DescresingList(list.append(lst, [elem]))
                False -> InvalidList
              }
            }
            Gt -> {
              case elem - last(lst) <= 3 {
                True -> IncreasingList(list.append(lst, [elem]))
                False -> InvalidList
              }
            }
            Eq -> InvalidList
          }
        }
        DescresingList(lst) -> {
          case last(lst) > elem && last(lst) - elem <= 3 {
            True -> DescresingList(list.append(lst, [elem]))
            False -> InvalidList
          }
        }
        IncreasingList(lst) -> {
          case last(lst) < elem && elem - last(lst) <= 3 {
            True -> IncreasingList(list.append(lst, [elem]))
            False -> InvalidList
          }
        }
      }
    })

  case result {
    InvalidList -> False
    UnknownList(_) -> False
    _ -> True
  }
}

pub fn run(input: String) {
  let lists =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      string.split(line, " ")
      |> list.map(fn(x) { utils.str_to_int(x) })
    })

  lists
  |> list.count(fn(x) { is_valid(x) })
  |> io.debug

  Nil
}
