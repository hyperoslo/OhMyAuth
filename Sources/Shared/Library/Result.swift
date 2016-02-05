enum Result<T> {
  case Success(T)
  case Failure(ErrorType?)
}
