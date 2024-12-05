import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string

type Input {
  Input(numbers: List(Int), processed: List(Int), is_valid: Bool)
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
    |> list.map(parse_int)

  Input(numbers, [], True)
}

fn parse_dependencies(lines) {
  let deps: Dict(Int, List(Int)) = dict.from_list([])
  lines
  |> string.split("\n")
  |> list.fold(deps, fn(acc, line) {
    case string.split(line, "|") {
      [int1, int2] -> {
        let int1 = parse_int(int1)
        let int2 = parse_int(int2)

        case dict.get(acc, int2) {
          Ok(values) -> dict.insert(acc, int2, [int1, ..values])
          _ -> dict.insert(acc, int2, [int1])
        }
      }
      _ -> panic as "Incorrect input"
    }
  })
}

fn parse_int(str: String) -> Int {
  case int.parse(str) {
    Ok(int) -> int
    _ -> panic as "Incorrect integer"
  }
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

fn mid_element(input: Input) {
  let len = list.length(input.numbers) - 1

  let val =
  input.numbers
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

  inputs
  |> list.filter(fn(i) { is_valid_input(i, dependencies) })
  |> list.map(mid_element)
  |> list.fold(0, fn(acc, i) { acc + i })
  |> io.debug()

  Nil
}
