export function extractSessionDataFromAuthClientResult(result: unknown): unknown | null {
  if (!result || typeof result !== 'object') {
    return null
  }

  const record = result as Record<string, unknown>

  // Expected shape from better-auth client: { data: <session> }
  if ('data' in record) {
    const data = (record as { data?: unknown }).data

    if (!data || typeof data !== 'object') {
      return null
    }

    const dataRecord = data as Record<string, unknown>

    if ('user' in dataRecord) {
      return data
    }

    if ('data' in dataRecord) {
      return dataRecord.data ?? null
    }

    return data
  }

  // Fallback for raw session payloads: { user, session }
  if ('user' in record) {
    return record
  }

  return null
}
