import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/string
import utils/utils

type Input {
  Input(
    numbers: List(Int),
    processed: List(Int),
    to_process: List(Int),
    is_valid: Bool,
  )
}

fn parse_inputs(lines) {
  lines
  |> string.split("\n")
  |> list.filter(fn(s) { s != "" })
  |> list.map(parse_input_line)
}

fn parse_input_line(line) {
  let numbers =
    line
    |> string.split(",")
    |> list.map(utils.str_to_int)

  Input(numbers, [], numbers, True)
}

fn parse_dependencies(lines) {
  let deps: Dict(Int, List(Int)) = dict.from_list([])
  lines
  |> string.split("\n")
  |> list.fold(deps, fn(acc, line) {
    case string.split(line, "|") {
      [int1, int2] -> {
        let int1 = utils.str_to_int(int1)
        let int2 = utils.str_to_int(int2)

        case dict.get(acc, int2) {
          Ok(values) -> dict.insert(acc, int2, [int1, ..values])
          _ -> dict.insert(acc, int2, [int1])
        }
      }
      _ -> panic as "Incorrect input"
    }
  })
}

fn is_valid_input(input: Input, dependencies) -> Bool {
  let out: Input =
    input.numbers
    |> list.fold(input, fn(acc_input, number) {
      case acc_input.is_valid {
        False -> acc_input
        True -> {
          let processed = [number, ..acc_input.processed]
          case dict.get(dependencies, number) {
            Ok(deps) -> {
              let is_valid =
                list.all(deps, fn(n) {
                  !list.contains(acc_input.numbers, n)
                  || list.contains(acc_input.processed, n)
                })
              Input(..acc_input, is_valid: is_valid, processed: processed)
            }
            _ -> Input(..acc_input, processed: processed, is_valid: True)
          }
        }
      }
    })

  out.is_valid
}

fn fix_input(input: Input, dependencies) {
  Input(..input, processed: [])
  |> do_fix_input(dependencies)
}

fn do_fix_input(input: Input, dependencies) {
  case input.to_process {
    [] -> input
    [hd, ..tail] -> {
      case dict.get(dependencies, hd) {
        Ok(deps) -> {
          case list.find(deps, fn(x) { list.contains(tail, x) }) {
            Ok(out_of_order_num) -> {
              let new_tail = [hd, ..utils.list_remove(tail, out_of_order_num)]
              Input(..input, to_process: [out_of_order_num, ..new_tail])
              |> do_fix_input(dependencies)
            }
            Error(_) ->
              Input(
                ..input,
                processed: [hd, ..input.processed],
                to_process: tail,
              )
              |> do_fix_input(dependencies)
          }
        }
        Error(_) ->
          Input(..input, processed: [hd, ..input.processed], to_process: tail)
          |> do_fix_input(dependencies)
      }
    }
  }
}

fn mid_element(lst) {
  let len = list.length(lst) - 1

  let val =
    lst
    |> list.index_map(fn(v, i) {
      case i == len / 2 {
        True -> v
        False -> -1
      }
    })
    |> list.find(fn(x) { x > 0 })

  case val {
    Ok(i) -> i
    _ -> panic as "No middle value"
  }
}

pub fn run(input) {
  let #(dependencies, inputs) = case string.split(input, "\n\n") {
    [part1, part2] -> {
      let dependencies = parse_dependencies(part1)
      let inputs = parse_inputs(part2)
      #(dependencies, inputs)
    }
    _ -> panic as "Incorrect input"
  }

  // part 1
  inputs
  |> list.filter(fn(i) { is_valid_input(i, dependencies) })
  |> list.map(fn(i) { mid_element(i.numbers) })
  |> list.fold(0, fn(acc, i) { acc + i })
  |> io.debug()

  // part 2
  inputs
  |> list.filter(fn(i) { !is_valid_input(i, dependencies) })
  |> list.map(fn(i) { fix_input(i, dependencies) })
  |> list.map(fn(i) { mid_element(i.processed) })
  |> list.fold(0, fn(acc, i) { acc + i })
  |> io.debug()

  Nil
}
