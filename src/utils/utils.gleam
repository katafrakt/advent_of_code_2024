import gleam/int

// Forcefully convert a string to an integer
pub fn str_to_int(s: String) -> Int {
  case int.parse(s) {
    Ok(i) -> i
    Error(_) -> panic as "Invalid input"
  }
}
