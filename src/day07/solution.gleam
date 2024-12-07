import gleam/io
import gleam/list
import gleam/string
import utils/utils

type Equation {
  Equation(target_value: Int, partial_value: Int, numbers_to_process: List(Int))
}

fn parse_line(line) {
  case string.split(line, ": ") {
    [p1, p2] -> {
      let target = utils.str_to_int(p1)
      let nums =
        string.split(p2, " ")
        |> list.map(utils.str_to_int)
      Equation(target_value: target, partial_value: 0, numbers_to_process: nums)
    }
    _ -> panic as "Incorrect format"
  }
}

fn can_achieve_target(equation: Equation) -> Bool {
  case equation.numbers_to_process {
    [] -> equation.partial_value == equation.target_value
    [hd, ..tail] -> {
      [
        Equation(..equation, partial_value: equation.partial_value + hd, numbers_to_process: tail),
        Equation(..equation, partial_value: equation.partial_value * hd, numbers_to_process: tail),
      ]
      |> list.map(can_achieve_target)
      |> list.any(fn(v) { v })
    }
  }
}

pub fn run(input) {
  input
  |> string.split("\n")
  |> list.filter(fn(l) { l != "" })
  |> list.map(parse_line)
  |> list.filter(can_achieve_target)
  |> list.fold(0, fn(acc, l) { acc + l.target_value })
  |> io.debug()

  Nil
}
