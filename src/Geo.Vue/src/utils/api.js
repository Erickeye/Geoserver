export function unwrap(response) {
  const result = response?.data ?? response
  return result?.data ?? null
}

export function isSuccess(response) {
  const result = response?.data ?? response
  return result?.isSuccess === true
}

export function getApiErrorMessage(error, fallback = '操作失敗') {
  const result = error?.response?.data ?? error?.data ?? error
  return result?.errorMessage ?? fallback
}
