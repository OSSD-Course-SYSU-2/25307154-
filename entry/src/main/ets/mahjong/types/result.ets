export interface Result<T> {
  success: boolean
  data: T | null
  errorCode: string | null
  errorMessage: string | null
}

export function createSuccess<T>(data: T): Result<T> {
  return { success: true, data: data, errorCode: null, errorMessage: null }
}

export function createError<T>(errorCode: string, errorMessage: string): Result<T> {
  return { success: false, data: null, errorCode: errorCode, errorMessage: errorMessage }
}
