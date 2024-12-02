import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils/utils

fn into_lists(elems, list1, list2) {
  case elems {
    [] -> #(
      list.sort(list1, by: int.compare),
      list.sort(list2, by: int.compare),
    )
    [[e1, e2], ..rest] ->
      into_lists(rest, list.append(list1, [e1]), list.append(list2, [e2]))
    _ -> panic as "Invalid input"
  }
}

fn sum_up_differences(lists: #(List(Int), List(Int)), sum: Int) -> Int {
  case lists.0 {
    [] -> sum
    [hd, ..tail] -> {
      case lists.1 {
        [] -> panic as "Invalid input"
        [hd2, ..tail2] -> {
          let new_sum = sum + int.absolute_value(hd - hd2)
          sum_up_differences(#(tail, tail2), new_sum)
        }
      }
    }
  }
}

fn similarity_score(lists: #(List(Int), List(Int)), sum: Int) -> Int {
  case lists.0 {
    [] -> sum
    [hd, ..tail] -> {
      let count = list.count(lists.1, fn(el) { el == hd })
      let score = hd * count
      similarity_score(#(tail, lists.1), sum + score)
    }
  }
}

pub fn run(input: String) {
  let lists =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      string.split(line, " ")
      |> list.filter(fn(x) { x != "" })
      |> list.map(fn(x) { utils.str_to_int(x) })
    })
    |> into_lists([], [])

  lists
  |> sum_up_differences(0)
  |> int.to_string()
  |> io.println()

  lists
  |> similarity_score(0)
  |> int.to_string()
  |> io.println()

  Nil
}
